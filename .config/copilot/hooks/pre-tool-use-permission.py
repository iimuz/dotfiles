#!/usr/bin/env python3
"""preToolUse hook: allow/deny/ask control for Copilot CLI tool invocations.

Requires: Python 3.9+
Input: JSON from stdin with toolName and toolArgs fields.
Output: JSON with permissionDecision (allow/deny/ask) or empty for default.
"""

import json
import os
import re
import sys
from datetime import date
from pathlib import Path

# --- Input ---------------------------------------------------------------- #

_input_raw = sys.stdin.read()
_data = json.loads(_input_raw)

TOOL_NAME: str = _data.get("toolName", "")
TOOL_ARGS = _data.get("toolArgs", "")
TS_MS = _data.get("timestamp", 0)
CWD: str = _data.get("cwd", "")

# --- Logging -------------------------------------------------------------- #

_log_dir = Path(
    os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"),
    "copilot",
    "hooks",
    "pre-tool-use-permission",
)
_log_dir.mkdir(parents=True, exist_ok=True)
_log_file = _log_dir / f"{date.today().isoformat()}.jsonl"


def _get_cmd() -> str:
    if TOOL_NAME != "bash":
        return ""
    try:
        args = json.loads(TOOL_ARGS) if isinstance(TOOL_ARGS, str) else TOOL_ARGS
        return (args.get("command", "") or "")[:500]
    except (json.JSONDecodeError, AttributeError):
        return ""


def _log_decision(decision: str, reason: str = "") -> None:
    entry = json.dumps(
        {
            "ts": int(TS_MS) if TS_MS else 0,
            "tool": TOOL_NAME,
            "decision": decision,
            "reason": reason,
            "cmd": _get_cmd(),
            "cwd": CWD,
        },
        ensure_ascii=False,
    )
    with open(_log_file, "a") as f:
        f.write(entry + "\n")


# --- Decision helpers ----------------------------------------------------- #


def deny(reason: str) -> None:
    _log_decision("deny", reason)
    print(json.dumps({"permissionDecision": "deny", "permissionDecisionReason": reason}))
    sys.exit(0)


def ask(reason: str) -> None:
    _log_decision("ask", reason)
    print(json.dumps({"permissionDecision": "ask", "permissionDecisionReason": reason}))
    sys.exit(0)


def allow() -> None:
    _log_decision("allow")
    print('{"permissionDecision":"allow"}')
    sys.exit(0)


def passthrough() -> None:
    _log_decision("passthrough")
    sys.exit(0)


# --- Non-bash tools: always allow ----------------------------------------- #

if TOOL_NAME in ("view", "grep", "glob", "edit", "create"):
    allow()

if TOOL_NAME != "bash":
    sys.exit(0)

# --- Bash command rules --------------------------------------------------- #

COMMAND = _get_cmd()
if not COMMAND:
    sys.exit(0)

HOME_DIR = os.environ.get("HOME", "")

# ---- ALLOW: trusted skill scripts --------------------------------------- #

_skill_user_re = re.compile(
    rf"(^|&&\s*)(bash\s+)?{re.escape(HOME_DIR)}/.copilot/skills/[^;&|]+\.sh(\s|$)"
)
_skill_project_re = re.compile(
    r"(^|&&\s*)(bash\s+)?([^\s]*/)?.config/copilot/skills/[^;&|]+\.sh(\s|$)"
)

if _skill_user_re.search(COMMAND):
    allow()

if _skill_project_re.search(COMMAND):
    allow()

# ---- ALLOW: read-only bash commands (allow-list approach) ---------------- #

SAFE_CMDS = frozenset([
    "cd", "echo", "printf", "cat", "grep", "rg", "find", "head", "tail",
    "ls", "which", "type", "wc", "sort", "uniq", "tr", "basename", "dirname",
    "test", "true", "false", "date",
])

SAFE_GIT_SUBS = frozenset([
    "add", "blame", "branch", "describe", "diff", "fetch", "for-each-ref",
    "log", "ls-files", "ls-remote", "ls-tree", "merge-base", "name-rev",
    "reflog", "rev-list", "rev-parse", "shortlog", "show", "stash",
    "status", "symbolic-ref", "tag", "version",
])

_GIT_SUB_RE = re.compile(r"git\s+(--no-pager\s+)?(\S+)")


def _is_safe_git(segment: str) -> bool:
    """Check if a git command segment uses only safe subcommands."""
    m = _GIT_SUB_RE.match(segment.strip())
    if not m:
        return False
    return m.group(2) in SAFE_GIT_SUBS


def _is_safe_command(cmd: str) -> bool:
    """Check all command-position words are in the safe list."""
    segments = re.split(r"&&|\|\||[;|]", cmd)
    for seg in segments:
        seg = seg.strip()
        if not seg:
            continue
        first_word = seg.split()[0]
        if first_word == "git":
            if not _is_safe_git(seg):
                return False
        elif first_word not in SAFE_CMDS:
            return False
    return True


if _is_safe_command(COMMAND):
    allow()

# ---- DENY: catastrophic / irreversible ----------------------------------- #

if re.search(r"(^|[;&|]\s*)rm\s", COMMAND) and re.search(
    r"\s-[a-zA-Z]*[rf]|--force|--recursive", COMMAND
):
    deny("rm with force/recursive flags is blocked")

if re.search(r"xargs\s+rm\s", COMMAND):
    deny("xargs rm is blocked")

if re.search(r"(^|[;&|]\s*)(sudo|su)\s", COMMAND):
    deny("Privilege escalation is blocked")

if re.search(r"(curl|wget)\s.*\|\s*(ba)?sh", COMMAND):
    deny("Remote code execution via pipe is blocked")

if re.search(r"(^|[;&|]\s*)(eval|exec)\s", COMMAND):
    deny("Dynamic code execution is blocked")

if re.search(r"(^|[;&|]\s*)(dd\s+if=|mkfs|fdisk)", COMMAND):
    deny("Disk destructive operation is blocked")

if re.search(r"chmod\s+777", COMMAND):
    deny("chmod 777 is blocked")

if re.search(r"git\s+push\s.*--force", COMMAND):
    deny("git push --force is blocked")

if re.search(r"git\s+reset\s.*--hard", COMMAND):
    deny("git reset --hard is blocked")

if re.search(r"git\s+clean\s.*-[a-zA-Z]*f", COMMAND):
    deny("git clean -f is blocked")

# ---- ASK: context-dependent --------------------------------------------- #

if re.search(r"git\s+push(\s|$)", COMMAND):
    ask("git push modifies remote")

if re.search(r"git\s+(checkout|switch)\s", COMMAND):
    ask("Branch switch may discard uncommitted changes")

if re.search(r"git\s+rebase(\s|$)", COMMAND):
    ask("git rebase rewrites history")

if re.search(r"npm\s+(remove|uninstall)(\s|$)", COMMAND):
    ask("npm package removal")

if re.search(r"(^|[;&|]\s*)kill\s", COMMAND):
    ask("Process termination")

if re.search(r"(^|[;&|]\s*)(ssh|scp)\s", COMMAND):
    ask("Remote access")

if re.search(r"sed\s.*-i", COMMAND):
    ask("In-place file modification with sed -i")

if re.search(r"gh\s+api\s", COMMAND) and re.search(
    r"--method\s+(PUT|PATCH|DELETE|POST)", COMMAND
):
    ask("gh api with write method")

# ---- DEFAULT: no decision, fall through to CLI flags --------------------- #
passthrough()
