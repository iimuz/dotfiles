"""Pytest configuration: make hook modules importable."""

import importlib.util
import sys
import types
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent


def _load_module(name: str, file_path: Path) -> None:
    """Load a Python file as a module, bypassing dotted-directory import issues."""
    if name in sys.modules:
        return
    spec = importlib.util.spec_from_file_location(name, file_path)
    if spec is None or spec.loader is None:
        msg = f"Cannot load {file_path}"
        raise ImportError(msg)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)


_load_module(
    "config.copilot.hooks.pre_tool_use_permission",
    _PROJECT_ROOT / ".config" / "copilot" / "hooks" / "pre-tool-use-permission.py",
)
_gh_ops = types.ModuleType("gh_ops")
sys.modules.setdefault("gh_ops", _gh_ops)

_load_module(
    "gh_ops.create_review",
    _PROJECT_ROOT / ".config" / "claude" / "skills" / "gh-ops" / "scripts" / "create_review.py",
)
_gh_ops.create_review = sys.modules["gh_ops.create_review"]

_load_module(
    "gh_ops.append_review",
    _PROJECT_ROOT / ".config" / "claude" / "skills" / "gh-ops" / "scripts" / "append_review.py",
)
_gh_ops.append_review = sys.modules["gh_ops.append_review"]
