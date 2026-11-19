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


_MISE_DIR = _REPO_ROOT / ".config" / "mise"


@pytest.mark.skipif(tomllib is None, reason="No TOML parser available (need tomllib or tomli)")
@pytest.mark.parametrize("platform_file", ["config-mac.toml", "config-linux.toml"])
def test_mise_platform_config_does_not_repeat_common_tools(platform_file: str) -> None:
    """A tool in the platform file would silently replace the common entry, options included."""
    common = tomllib.loads((_MISE_DIR / "config-common.toml").read_text())["tools"]
    platform = tomllib.loads((_MISE_DIR / platform_file).read_text()).get("tools", {})
    assert set(common) & set(platform) == set()


# ---------------------------------------------------------------------------
# 3. JSON files parse
# ---------------------------------------------------------------------------

_JSON_FILES = _git_ls_files("*.json")


@pytest.mark.parametrize(
    "json_file",
    _JSON_FILES,
    ids=[str(Path(p).name) for p in _JSON_FILES],
)
def test_json_files_parse(json_file: str) -> None:
    """Every tracked ``*.json`` file is valid JSON."""
    path = _REPO_ROOT / json_file
    json.loads(path.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# 5. Claude Code settings.json script references
# ---------------------------------------------------------------------------

# setup_*.sh が張る link を通して、settings.json の $HOME 配下のパスをリポジトリのパスに読み替える
_HOME_LINKS = {
    "$HOME/.config/agents/": ".config/agents/",
    "$HOME/.claude/hooks/": ".config/claude/hooks/",
    "$HOME/.claude/statusline.py": ".config/claude/statusline.py",
}
_HOME_PATH_RE = re.compile(r"""\$HOME/[a-zA-Z0-9_./-]+""")


def _settings_commands(settings: dict) -> list[str]:
    commands = [
        hook["command"]
        for groups in settings.get("hooks", {}).values()
        for group in groups
        for hook in group.get("hooks", [])
        if "command" in hook
    ]
    if "command" in settings.get("statusLine", {}):
        commands.append(settings["statusLine"]["command"])
    return commands


def _settings_script_references() -> list[str]:
    settings_path = _REPO_ROOT / ".config/claude/settings.json"
    settings = json.loads(settings_path.read_text(encoding="utf-8"))
    return [
        match
        for command in _settings_commands(settings)
        for match in _HOME_PATH_RE.findall(command)
    ]


@pytest.mark.parametrize("script", ["setup_mac.sh", "setup_aarch64.sh"])
@pytest.mark.parametrize("home_prefix, repo_prefix", list(_HOME_LINKS.items()))
def test_setup_creates_home_links(script: str, home_prefix: str, repo_prefix: str) -> None:
    """The setup scripts that install Claude Code create every link in ``_HOME_LINKS``."""
    expected = f'create_symlink "$SCRIPT_DIR/{repo_prefix.rstrip("/")}" "{home_prefix.rstrip("/")}"'
    content = (_REPO_ROOT / script).read_text(encoding="utf-8")
    assert expected in content, f"{script} does not run: {expected}"


@pytest.mark.parametrize("home_path", _settings_script_references())
def test_settings_command_references_exist(home_path: str) -> None:
    """Every ``$HOME/...`` script in settings.json maps to a tracked repository path."""
    for prefix, repo_prefix in _HOME_LINKS.items():
        if home_path.startswith(prefix):
            repo_path = repo_prefix + home_path[len(prefix) :]
            assert _git_ls_files(repo_path) == [repo_path], (
                f"{home_path} -> {repo_path} is not tracked"
            )
            return
    pytest.fail(f"{home_path} is not under a path that setup_*.sh links into the repository")
