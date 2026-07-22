#!/usr/bin/env python3
"""RunCat Neo - Claude Code usage metrics for the statusLine command.

Invoked by Claude Code as its ``statusLine.command``. On each turn it:

1. reads the statusLine JSON payload from stdin,
2. writes a RunCat Neo custom-metrics snapshot to ``~/.claude/runcat-usage.json``
   (5h / 7d rate-limit usage and the current-month API-cost estimate),
3. relays the existing ``ccstatusline`` output to stdout so the terminal status
   line is unchanged.

The monthly cost comes from ``ccusage`` and is refreshed lazily in a detached
background process (TTL-cached) so the status line never blocks.

Register the output file in RunCat Neo via
Settings -> Metrics -> Custom Metrics -> Add Custom Metrics Source
and choose ``~/.claude/runcat-usage.json`` (macOS only).

Usage:
    (no args)        statusLine path (default)
    --refresh-cost   recompute the monthly-cost cache, then exit
"""

from __future__ import annotations

import contextlib
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

TITLE = "Claude Code"
SYMBOL = "staroflife"
COST_TTL_SECONDS = 600
LOCK_MAX_AGE_SECONDS = 120

CLAUDE_DIR = Path(os.environ.get("CLAUDE_CONFIG_DIR") or (Path.home() / ".claude"))
OUT_FILE = Path(os.environ.get("RUNCAT_OUT_FILE") or (CLAUDE_DIR / "runcat-usage.json"))
COST_CACHE_FILE = CLAUDE_DIR / "runcat-cost-cache.json"
COST_LOCK_FILE = CLAUDE_DIR / "runcat-cost-cache.lock"


# --- pure logic ----------------------------------------------------------- #


def _as_float(value: object) -> float | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, (int, float)):
        return float(value)
    return None


def _clamp01(value: float) -> float:
    return max(0.0, min(1.0, value))


def extract_percentages(payload: dict) -> tuple[float | None, float | None]:
    """Return (five_hour, seven_day) used-percentage floats, or None if absent."""
    rate_limits = payload.get("rate_limits") or {}
    five = (rate_limits.get("five_hour") or {}).get("used_percentage")
    seven = (rate_limits.get("seven_day") or {}).get("used_percentage")
    return _as_float(five), _as_float(seven)


def _metric_row(title: str, pct: float) -> dict:
    return {
        "title": title,
        "formattedValue": f"{pct:.1f}%",
        "normalizedValue": round(_clamp01(pct / 100.0), 4),
    }


def format_cost(cost: float | None) -> str | None:
    """Format a USD cost as ``$1234.56``; None when unavailable."""
    if cost is None:
        return None
    return f"${cost:.2f}"


def build_output(
    five: float | None,
    seven: float | None,
    cost: float | None,
    now: datetime,
) -> dict:
    """Build the RunCat Neo custom-metrics dict from the three signals."""
    metrics: list[dict] = []
    if five is not None:
        metrics.append(_metric_row("5h", five))
    if seven is not None:
        metrics.append(_metric_row("7d", seven))
    cost_text = format_cost(cost)
    if cost_text is not None:
        metrics.append({"title": "Cost", "formattedValue": cost_text})

    if five is not None:
        bar = f"{five:.1f}%"
    elif seven is not None:
        bar = f"{seven:.1f}%"
    else:
        bar = ""

    return {
        "title": TITLE,
        "symbol": SYMBOL,
        "metricsBarValue": bar,
        "metrics": metrics,
        "lastUpdatedDate": now.strftime("%Y-%m-%dT%H:%M:%SZ"),
    }


def parse_month_cost(ccusage_data: dict, month: str) -> float | None:
    """Return totalCost for the ``YYYY-MM`` period, else the latest month's cost."""
    monthly = ccusage_data.get("monthly") if isinstance(ccusage_data, dict) else None
    if not isinstance(monthly, list) or not monthly:
        return None
    for entry in monthly:
        if isinstance(entry, dict) and entry.get("period") == month:
            return _as_float(entry.get("totalCost"))
    last = monthly[-1]
    return _as_float(last.get("totalCost")) if isinstance(last, dict) else None


def cost_from_cache(
    cache: object,
    now: datetime,
    ttl_seconds: int,
) -> tuple[float | None, bool]:
    """Return (cost, is_fresh) from a parsed cache dict."""
    if not isinstance(cache, dict):
        return None, False
    cost = _as_float(cache.get("costUsd"))
    updated_at = cache.get("updatedAt")
    if not isinstance(updated_at, str):
        return cost, False
    try:
        ts = datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    except ValueError:
        return cost, False
    return cost, (now - ts).total_seconds() < ttl_seconds


# --- I/O ------------------------------------------------------------------- #


def read_json_file(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def atomic_write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    tmp.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    os.replace(tmp, path)


def parse_payload(raw: str) -> dict:
    try:
        payload = json.loads(raw)
    except (ValueError, TypeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def maybe_spawn_refresh(now: datetime) -> None:
    """Spawn a detached cost refresh when the cache is stale and none is running."""
    cache = read_json_file(COST_CACHE_FILE)
    _, fresh = cost_from_cache(cache, now, COST_TTL_SECONDS)
    if fresh:
        return
    try:
        age = time.time() - COST_LOCK_FILE.stat().st_mtime
        if age < LOCK_MAX_AGE_SECONDS:
            return
    except OSError:
        pass
    try:
        COST_LOCK_FILE.parent.mkdir(parents=True, exist_ok=True)
        COST_LOCK_FILE.touch()
        subprocess.Popen(
            [sys.executable, os.path.realpath(__file__), "--refresh-cost"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError:
        pass


def _run_ccusage(exe: str) -> object:
    for args in (["monthly", "--json", "--offline"], ["monthly", "--json"]):
        try:
            result = subprocess.run(
                [exe, *args],
                capture_output=True,
                text=True,
                timeout=120,
                check=False,
            )
        except (OSError, subprocess.SubprocessError):
            continue
        if result.returncode == 0 and result.stdout.strip():
            try:
                return json.loads(result.stdout)
            except ValueError:
                continue
    return None


def refresh_cost(now: datetime) -> None:
    """Recompute the monthly-cost cache from ccusage (background entry point)."""
    try:
        exe = shutil.which("ccusage")
        if not exe:
            return
        data = _run_ccusage(exe)
        if not isinstance(data, dict):
            return
        month = time.strftime("%Y-%m", time.localtime())
        cost = parse_month_cost(data, month)
        if cost is None:
            return
        atomic_write_json(
            COST_CACHE_FILE,
            {
                "costUsd": cost,
                "month": month,
                "updatedAt": now.strftime("%Y-%m-%dT%H:%M:%SZ"),
            },
        )
    finally:
        with contextlib.suppress(OSError):
            COST_LOCK_FILE.unlink()


def relay_ccstatusline(raw: str, payload: dict) -> None:
    """Relay ccstatusline output; fall back to the model name if unavailable."""
    exe = shutil.which("ccstatusline")
    if exe:
        try:
            result = subprocess.run(
                [exe],
                input=raw,
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
            if result.returncode == 0 and result.stdout:
                sys.stdout.write(result.stdout)
                return
        except (OSError, subprocess.SubprocessError):
            pass
    model = (payload.get("model") or {}).get("display_name") or TITLE
    print(model)


def main(argv: list[str]) -> None:
    now = datetime.now(timezone.utc)
    if "--refresh-cost" in argv:
        refresh_cost(now)
        return
    try:
        raw = sys.stdin.read()
    except OSError:
        raw = ""
    payload = parse_payload(raw)
    five, seven = extract_percentages(payload)
    maybe_spawn_refresh(now)
    cost, _ = cost_from_cache(read_json_file(COST_CACHE_FILE), now, COST_TTL_SECONDS)
    with contextlib.suppress(OSError):
        atomic_write_json(OUT_FILE, build_output(five, seven, cost, now))
    relay_ccstatusline(raw, payload)


if __name__ == "__main__":
    main(sys.argv[1:])
