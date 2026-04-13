"""Pytest configuration: make hook modules importable."""

import importlib.util
import sys
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
