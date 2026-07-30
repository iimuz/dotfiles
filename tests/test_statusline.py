"""Tests for the RunCat Neo statusLine wrapper (pure logic)."""

from datetime import datetime, timedelta, timezone

from config.claude.statusline import (
    build_output,
    build_statusline,
    cost_from_cache,
    extract_percentages,
    format_cost,
    format_reset_datetime,
    format_reset_delta,
    parse_month_cost,
)

NOW = datetime(2026, 7, 22, 0, 0, 0, tzinfo=timezone.utc)


class TestExtractPercentages:
    def test_reads_both(self) -> None:
        payload = {
            "rate_limits": {
                "five_hour": {"used_percentage": 16.4},
                "seven_day": {"used_percentage": 1.0},
            }
        }
        assert extract_percentages(payload) == (16.4, 1.0)

    def test_missing_rate_limits(self) -> None:
        assert extract_percentages({}) == (None, None)

    def test_partial(self) -> None:
        payload = {"rate_limits": {"five_hour": {"used_percentage": 5}}}
        assert extract_percentages(payload) == (5.0, None)

    def test_bool_is_ignored(self) -> None:
        payload = {"rate_limits": {"five_hour": {"used_percentage": True}}}
        assert extract_percentages(payload) == (None, None)


class TestFormatCost:
    def test_formats(self) -> None:
        assert format_cost(12.3456) == "$12.35"

    def test_none(self) -> None:
        assert format_cost(None) is None


class TestBuildOutput:
    def test_all_three(self) -> None:
        out = build_output(16.4, 1.0, 12.34, NOW)
        assert out["title"] == "Claude Code"
        assert out["symbol"] == "staroflife"
        assert out["metricsBarValue"] == "16.4%"
        assert out["lastUpdatedDate"] == "2026-07-22T00:00:00Z"
        assert out["metrics"] == [
            {"title": "5h", "formattedValue": "16.4%", "normalizedValue": 0.164},
            {"title": "7d", "formattedValue": "1.0%", "normalizedValue": 0.01},
            {"title": "Cost", "formattedValue": "$12.34"},
        ]

    def test_cost_row_has_no_bar(self) -> None:
        out = build_output(None, None, 5.0, NOW)
        assert out["metrics"] == [{"title": "Cost", "formattedValue": "$5.00"}]
        assert out["metricsBarValue"] == ""

    def test_omits_missing_signals(self) -> None:
        out = build_output(None, None, None, NOW)
        assert out["metrics"] == []
        assert out["metricsBarValue"] == ""

    def test_bar_falls_back_to_seven(self) -> None:
        out = build_output(None, 2.5, None, NOW)
        assert out["metricsBarValue"] == "2.5%"

    def test_normalized_is_clamped(self) -> None:
        out = build_output(150.0, -10.0, None, NOW)
        assert out["metrics"][0]["normalizedValue"] == 1.0
        assert out["metrics"][1]["normalizedValue"] == 0.0


class TestParseMonthCost:
    def _data(self) -> dict:
        return {
            "monthly": [
                {"period": "2026-06", "totalCost": 100.0},
                {"period": "2026-07", "totalCost": 200.5},
            ]
        }

    def test_matches_period(self) -> None:
        assert parse_month_cost(self._data(), "2026-07") == 200.5

    def test_falls_back_to_latest(self) -> None:
        assert parse_month_cost(self._data(), "2026-08") == 200.5

    def test_empty(self) -> None:
        assert parse_month_cost({"monthly": []}, "2026-07") is None

    def test_not_a_dict(self) -> None:
        assert parse_month_cost([], "2026-07") is None


class TestCostFromCache:
    def test_fresh(self) -> None:
        cache = {"costUsd": 12.34, "updatedAt": "2026-07-21T23:55:00Z"}
        assert cost_from_cache(cache, NOW, 600) == (12.34, True)

    def test_stale(self) -> None:
        cache = {"costUsd": 12.34, "updatedAt": "2026-07-21T23:00:00Z"}
        assert cost_from_cache(cache, NOW, 600) == (12.34, False)

    def test_missing(self) -> None:
        assert cost_from_cache(None, NOW, 600) == (None, False)

    def test_bad_timestamp(self) -> None:
        cache = {"costUsd": 12.34, "updatedAt": "nonsense"}
        assert cost_from_cache(cache, NOW, 600) == (12.34, False)


class TestFormatResetDatetime:
    def test_utc(self) -> None:
        ts = datetime(2026, 8, 3, 5, 0, tzinfo=timezone.utc).timestamp()
        assert format_reset_datetime(ts, timezone.utc) == "08/03 05:00"

    def test_timezone_conversion(self) -> None:
        ts = datetime(2026, 8, 2, 20, 0, tzinfo=timezone.utc).timestamp()
        jst = timezone(timedelta(hours=9))
        assert format_reset_datetime(ts, jst) == "08/03 05:00"

    def test_int_epoch_seconds(self) -> None:
        assert format_reset_datetime(0, timezone.utc) == "01/01 00:00"

    def test_invalid_inputs(self) -> None:
        assert format_reset_datetime(None, timezone.utc) is None
        assert format_reset_datetime(True, timezone.utc) is None
        assert format_reset_datetime("1700000000", timezone.utc) is None


def test_format_reset_delta_minutes():
    assert format_reset_delta(34 * 60) == "34m"


def test_format_reset_delta_hours_minutes():
    assert format_reset_delta(1 * 3600 + 23 * 60) == "1h23m"


def test_format_reset_delta_days_hours():
    assert format_reset_delta(2 * 86400 + 4 * 3600) == "2d4h"


def test_format_reset_delta_zero_minutes():
    assert format_reset_delta(30) == "0m"


def test_format_reset_delta_invalid():
    assert format_reset_delta(0) is None
    assert format_reset_delta(-5) is None
    assert format_reset_delta(True) is None
    assert format_reset_delta("60") is None
    assert format_reset_delta(None) is None


NOW_STATUSLINE = 1_700_000_000.0

FULL_PAYLOAD = {
    "model": {"display_name": "Opus 4.8"},
    "context_window": {"used_percentage": 34.2},
    "rate_limits": {
        "five_hour": {"used_percentage": 42.0, "resets_at": NOW_STATUSLINE + 4980},
        "seven_day": {"used_percentage": 61.0, "resets_at": NOW_STATUSLINE + 2 * 86400 + 4 * 3600},
    },
}


def test_build_statusline_full():
    assert build_statusline(FULL_PAYLOAD, NOW_STATUSLINE) == (
        "\x1b[36mOpus 4.8\x1b[0m | \x1b[90mCtx: 34%\x1b[0m | 5h: 42% (1h23m) | 7d: 61% (2d4h)"
    )


def test_build_statusline_without_rate_limits():
    payload = {
        "model": {"display_name": "Opus 4.8"},
        "context_window": {"used_percentage": 34.2},
    }
    assert build_statusline(payload, NOW_STATUSLINE) == (
        "\x1b[36mOpus 4.8\x1b[0m | \x1b[90mCtx: 34%\x1b[0m"
    )


def test_build_statusline_rate_limit_without_reset():
    payload = {"rate_limits": {"five_hour": {"used_percentage": 42.0}}}
    assert build_statusline(payload, NOW_STATUSLINE) == "5h: 42%"


def test_build_statusline_empty_payload():
    assert build_statusline({}, NOW_STATUSLINE) == "Claude Code"


def test_build_statusline_rejects_bool_percentage():
    payload = {"context_window": {"used_percentage": True}}
    assert build_statusline(payload, NOW_STATUSLINE) == "Claude Code"
