"""Tests for the RunCat Neo statusLine wrapper (pure logic)."""

from datetime import datetime, timezone

from config.claude.runcat_statusline import (
    build_output,
    cost_from_cache,
    extract_percentages,
    format_cost,
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
