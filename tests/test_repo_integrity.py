"""Repository integrity tests.

Ensures that path references in setup/update scripts point to files that
actually exist, and that committed TOML / JSON files are parseable.
"""

import json
import re
import subprocess
from pathlib import Path

import pytest

_REPO_ROOT = Path(__file__).resolve().parents[1]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _git_ls_files(*patterns: str) -> list[str]:
    """Return tracked files matching the given git pathspec patterns."""
    result = subprocess.run(
        ["git", "ls-files", *patterns],
        capture_output=True,
        text=True,
        cwd=_REPO_ROOT,
    )
    return [line for line in result.stdout.splitlines() if line]


_SCRIPT_RE = re.compile(r"""\$SCRIPT_DIR/([a-zA-Z0-9_./-]+)""")
_CONFIG_RE = re.compile(r"""\$CONFIG_PATH/([a-zA-Z0-9_./-]+)""")


def _extract_path_references(script_path: Path) -> list[tuple[str, str]]:
    """Extract ``$SCRIPT_DIR/...`` and ``$CONFIG_PATH/...`` references.

    Returns a list of ``(variable, relative_path)`` tuples where *variable*
    is ``SCRIPT_DIR`` or ``CONFIG_PATH`` and *relative_path* is the path
    portion after the slash.

    Lines that are shell comments (leading ``#`` after whitespace) are
    skipped.  References whose captured path contains a ``$`` character are
    also skipped (they reference other shell variables and cannot be resolved
    statically).
    """
    references: list[tuple[str, str]] = []
    for line in script_path.read_text().splitlines():
        stripped = line.lstrip()
        if stripped.startswith("#"):
            continue
        for match in _SCRIPT_RE.finditer(line):
            path = match.group(1)
            if "$" in path:
                continue
            references.append(("SCRIPT_DIR", path))
        for match in _CONFIG_RE.finditer(line):
            path = match.group(1)
            if "$" in path:
                continue
            references.append(("CONFIG_PATH", path))
    return references


def _resolve_ref(variable: str, relative_path: str) -> Path:
    """Resolve a ``$SCRIPT_DIR`` or ``$CONFIG_PATH`` reference to an absolute path."""
    if variable == "SCRIPT_DIR":
        return _REPO_ROOT / relative_path
    # CONFIG_PATH is always $SCRIPT_DIR/.config
    return _REPO_ROOT / ".config" / relative_path


# ---------------------------------------------------------------------------
# 1. Setup script path references
# ---------------------------------------------------------------------------


def _collect_script_refs() -> list[tuple[str, str, str]]:
    """Collect all path references across setup/update scripts.

    Returns tuples of ``(script_name, variable, relative_path)``.
    """
    scripts = _git_ls_files("setup_*.sh", "update_*.sh")
    refs: list[tuple[str, str, str]] = []
    for script in scripts:
        for variable, rel_path in _extract_path_references(_REPO_ROOT / script):
            refs.append((script, variable, rel_path))
    return refs


_SCRIPT_REFS = _collect_script_refs()


@pytest.mark.parametrize(
    "script, variable, relative_path",
    _SCRIPT_REFS,
    ids=[f"{s}::{v}/{p}" for s, v, p in _SCRIPT_REFS],
)
def test_setup_script_references_exist(script: str, variable: str, relative_path: str) -> None:
    """Every ``$SCRIPT_DIR/...`` and ``$CONFIG_PATH/...`` reference resolves to an existing path."""
    resolved = _resolve_ref(variable, relative_path)
    assert resolved.exists(), (
        f"{script} references {variable}/{relative_path} "
        f"which resolves to {resolved} but it does not exist"
    )


# ---------------------------------------------------------------------------
# 2. TOML files parse
# ---------------------------------------------------------------------------

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:
    try:
        import tomli as tomllib  # type: ignore[no-redef]
    except ModuleNotFoundError:
        tomllib = None  # type: ignore[assignment]

_TOML_FILES = _git_ls_files("*.toml")


@pytest.mark.skipif(tomllib is None, reason="No TOML parser available (need tomllib or tomli)")
@pytest.mark.parametrize(
    "toml_file",
    _TOML_FILES,
    ids=[str(Path(p).name) for p in _TOML_FILES],
)
def test_toml_files_parse(toml_file: str) -> None:
    """Every tracked ``*.toml`` file is valid TOML."""
    path = _REPO_ROOT / toml_file
    with path.open("rb") as f:
        tomllib.load(f)


# ---------------------------------------------------------------------------
# 3. JSON files parse
# ---------------------------------------------------------------------------

# devcontainer.json allows comments by specification (JSONC), so it is
# excluded from strict JSON validation.
_JSON_EXCLUDES = {".devcontainer/devcontainer.json"}
_JSON_FILES = [f for f in _git_ls_files("*.json") if f not in _JSON_EXCLUDES]


@pytest.mark.parametrize(
    "json_file",
    _JSON_FILES,
    ids=[str(Path(p).name) for p in _JSON_FILES],
)
def test_json_files_parse(json_file: str) -> None:
    """Every tracked ``*.json`` file is valid JSON."""
    path = _REPO_ROOT / json_file
    raw = path.read_bytes()
    # Try common encodings: UTF-8 is standard; UTF-8-sig handles BOM;
    # UTF-16-LE covers files exported by Windows tools (e.g. scoop).
    for encoding in ("utf-8", "utf-8-sig", "utf-16"):
        try:
            text = raw.decode(encoding)
            break
        except (UnicodeDecodeError, ValueError):
            continue
    else:
        msg = f"{json_file}: none of UTF-8/UTF-8-sig/UTF-16 could decode the file"
        raise AssertionError(msg)
    json.loads(text)
