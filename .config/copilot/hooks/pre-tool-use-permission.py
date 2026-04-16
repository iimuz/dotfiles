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

# --- Constants ------------------------------------------------------------ #

SAFE_TOOLS = frozenset(["view", "grep", "glob", "edit", "create"])

SAFE_CMDS = frozenset(
    [
        "awk",
        "cd",
        "cp",
        "echo",
        "printf",
        "cat",
        "grep",
        "rg",
        "find",
        "head",
        "tail",
        "ls",
        "mkdir",
        "which",
        "type",
        "wc",
        "sort",
        "uniq",
        "tr",
        "sed",
        "basename",
        "dirname",
        "test",
        "true",
        "false",
        "date",
        "diff",
        "file",
        "jq",
        "readlink",
        "realpath",
        "shellcheck",
        "stat",
        "tput",
        "xargs",
    ]
)

SHELL_KEYWORDS = frozenset(
    [
        "for",
        "while",
        "do",
        "done",
        "if",
        "then",
        "else",
        "fi",
        "in",
        "case",
        "esac",
    ]
)

SAFE_GIT_SUBS = frozenset(
    [
        "add",
        "blame",
        "branch",
        "check-ignore",
        "clone",
        "describe",
        "diff",
        "fetch",
        "for-each-ref",
        "help",
        "init",
        "log",
        "ls-files",
        "ls-remote",
        "ls-tree",
        "merge-base",
        "name-rev",
        "reflog",
        "rev-list",
        "rev-parse",
        "shortlog",
        "show",
        "status",
        "symbolic-ref",
        "tag",
        "version",
        "worktree",
    ]
)

_GIT_SUB_RE = re.compile(r"git\s+(--no-pager\s+)?(\S+)")

SAFE_GH_SUBS = frozenset(
    [
        "api",
        "issue",
        "pr",
        "repo",
        "run",
        "search",
        "status",
    ]
)

SAFE_GH_ACTIONS = frozenset(
    [
        "checks",
        "diff",
        "list",
        "status",
        "view",
    ]
)

SAFE_CARGO_SUBS = frozenset(
    [
        "bench",
        "build",
        "check",
        "clippy",
        "doc",
        "fmt",
        "search",
        "test",
        "tree",
    ]
)

SAFE_MISE_SUBS = frozenset(
    [
        "bin-paths",
        "completion",
        "config",
        "doctor",
        "ls",
        "ls-remote",
        "outdated",
        "plugins",
        "registry",
        "run",
        "search",
        "settings",
        "tasks",
        "tool",
        "version",
        "where",
        "which",
    ]
)

SAFE_DOCKER_SUBS = frozenset(
    [
        "images",
        "info",
        "inspect",
        "logs",
        "ps",
        "stats",
        "top",
        "version",
    ]
)

SAFE_COMPOSE_SUBS = frozenset(
    [
        "build",
        "config",
        "create",
        "down",
        "images",
        "logs",
        "ls",
        "port",
        "ps",
        "pull",
        "restart",
        "start",
        "stop",
        "top",
        "up",
        "version",
    ]
)

SAFE_STANDALONE_CMDS = frozenset(
    [
        "lefthook",
        "markdownlint",
        "zizmor",
    ]
)


# --- Pure evaluation functions -------------------------------------------- #

_VAR_ASSIGN_RE = re.compile(r"^[A-Za-z_][A-Za-z_0-9]*=[^$`]*$")


def split_command_segments(cmd: str) -> list[str]:
    """Split command on &&, ||, ;, | while respecting quotes."""
    segments: list[str] = []
    current: list[str] = []
    in_single = False
    in_double = False
    i = 0
    length = len(cmd)
    while i < length:
        c = cmd[i]
        if c == "'" and not in_double:
            in_single = not in_single
            current.append(c)
        elif c == '"' and not in_single:
            in_double = not in_double
            current.append(c)
        elif c == "\\" and not in_single and i + 1 < length:
            current.append(c)
            current.append(cmd[i + 1])
            i += 1
        elif not in_single and not in_double:
            if (c == "&" and i + 1 < length and cmd[i + 1] == "&") or (
                c == "|" and i + 1 < length and cmd[i + 1] == "|"
            ):
                segments.append("".join(current))
                current = []
                i += 1
            elif c in (";", "|", "\n"):
                segments.append("".join(current))
                current = []
            else:
                current.append(c)
        else:
            current.append(c)
        i += 1
    if current:
        segments.append("".join(current))
    return segments


def strip_var_assignments(seg: str) -> str:
    """Strip leading variable assignments (VAR=literal) from a segment.

    Only strips assignments without command substitution ($() or backticks).
    """
    words = seg.split()
    while words and "=" in words[0]:
        candidate = words[0]
        if _VAR_ASSIGN_RE.match(candidate):
            words = words[1:]
        else:
            break
    return " ".join(words)


def parse_command(tool_name: str, tool_args: object) -> str:
    """Extract the bash command string from tool arguments."""
    if tool_name != "bash":
        return ""
    try:
        args = json.loads(tool_args) if isinstance(tool_args, str) else tool_args
        return (args.get("command", "") or "")[:500]
    except (json.JSONDecodeError, AttributeError):
        return ""


def is_safe_git(segment: str) -> bool:
    """Check if a git command segment uses only safe subcommands."""
    m = _GIT_SUB_RE.match(segment.strip())
    if not m:
        return False
    sub = m.group(2)
    if sub not in SAFE_GIT_SUBS:
        return False
    # Reject destructive operations on otherwise-safe subcommands
    if sub == "branch" and re.search(r"\s-[dD]\b", segment):
        return False
    if sub == "tag" and re.search(r"\s-d\b", segment):
        return False
    return not (sub == "worktree" and re.search(r"\s(add|remove|prune)\b", segment))


def is_safe_gh(segment: str) -> bool:
    """Check if a gh CLI command is read-only."""
    m = re.match(r"gh\s+(\S+)(?:\s+(\S+))?", segment.strip())
    if not m:
        return False
    sub = m.group(1)
    action = m.group(2) or ""
    if sub == "api":
        if re.search(r"\bgraphql\b", segment):
            return False
        return not re.search(r"--method\s+(PUT|PATCH|DELETE|POST)", segment)
    return sub in SAFE_GH_SUBS and action in SAFE_GH_ACTIONS


def is_safe_cargo(segment: str) -> bool:
    """Check if a cargo command uses only safe subcommands."""
    m = re.match(r"cargo\s+(\S+)", segment.strip())
    if not m:
        return False
    return m.group(1) in SAFE_CARGO_SUBS


def is_safe_mise(segment: str) -> bool:
    """Check if a mise command uses only safe (readonly) subcommands."""
    m = re.match(r"mise\s+(\S+)", segment.strip())
    if not m:
        return False
    return m.group(1) in SAFE_MISE_SUBS


def is_safe_docker(segment: str) -> bool:
    """Check if a docker command is safe."""
    m = re.match(r"docker\s+(\S+)(?:\s+(\S+))?", segment.strip())
    if not m:
        return False
    sub = m.group(1)
    action = m.group(2) or ""
    if sub == "compose":
        return action in SAFE_COMPOSE_SUBS
    return sub in SAFE_DOCKER_SUBS


def is_safe_curl(segment: str) -> bool:
    """Check if a curl command is GET-only (no write flags)."""
    write_flags = re.compile(
        r"\s(-X\s+(POST|PUT|PATCH|DELETE)"
        r"|--request\s+(POST|PUT|PATCH|DELETE)"
        r"|-d\s|-d$|--data\b|--data-\w+"
        r"|--upload-file\b|-T\s"
        r"|-F\s|-F$|--form\b)"
    )
    return not write_flags.search(segment)


def strip_rtk_prefix(seg: str) -> str:
    """Strip leading 'rtk' proxy prefix from a command segment."""
    words = seg.split()
    if words and words[0] == "rtk":
        return " ".join(words[1:])
    return seg


def is_safe_command(cmd: str) -> bool:
    """Check all command-position words are in the safe list."""
    segments = split_command_segments(cmd)
    for seg in segments:
        seg = seg.strip()
        if not seg:
            continue
        seg = strip_var_assignments(seg)
        if not seg:
            continue
        seg = strip_rtk_prefix(seg)
        if not seg:
            continue
        first_word = seg.split()[0]
        if first_word in SHELL_KEYWORDS:
            continue
        if first_word == "git":
            if not is_safe_git(seg):
                return False
        elif first_word == "gh":
            if not is_safe_gh(seg):
                return False
        elif first_word == "cargo":
            if not is_safe_cargo(seg):
                return False
        elif first_word == "mise":
            if not is_safe_mise(seg):
                return False
        elif first_word == "docker":
            if not is_safe_docker(seg):
                return False
        elif first_word == "curl":
            if not is_safe_curl(seg):
                return False
        elif first_word == "sed":
            if re.search(r"\s-[a-zA-Z]*i", seg):
                return False
        elif first_word == "xargs":
            xargs_words = seg.split()
            xargs_cmd = next((w for w in xargs_words[1:] if not w.startswith("-")), None)
            if xargs_cmd and xargs_cmd not in SAFE_CMDS:
                return False
        elif first_word in SAFE_STANDALONE_CMDS:
            continue
        elif first_word not in SAFE_CMDS:
            return False
    return True


def evaluate(
    tool_name: str,
    command: str,
    home_dir: str,
) -> tuple[str, str]:
    """Evaluate a tool invocation and return (decision, reason).

    Returns one of:
      ("allow", "")           - auto-approve
      ("deny", "<reason>")    - block with reason
      ("ask", "<reason>")     - prompt user with reason
      ("passthrough", "")     - no decision, defer to CLI defaults
      ("exit", "")            - non-bash non-safe tool, emit nothing
    """
    # Non-bash tools
    if tool_name in SAFE_TOOLS:
        return ("allow", "")
    if tool_name != "bash":
        return ("exit", "")

    if not command:
        return ("exit", "")

    # Trusted skill scripts
    skill_user_re = re.compile(
        rf"(^|&&\s*)(bash\s+)?{re.escape(home_dir)}/.copilot/skills/[^;&|]+\.sh(\s|$)"
    )
    skill_project_re = re.compile(
        r"(^|&&\s*)(bash\s+)?([^\s]*/)?.config/copilot/skills/[^;&|]+\.sh(\s|$)"
    )
    if skill_user_re.search(command):
        return ("allow", "")
    if skill_project_re.search(command):
        return ("allow", "")

    # Read-only commands (allow-list)
    if is_safe_command(command):
        return ("allow", "")

    # Deny: catastrophic / irreversible
    deny_rules: list[tuple[str, str]] = [
        (r"(^|[;&|]\s*)rm\s", "rm_flags"),
        (r"xargs\s+rm\s", "xargs rm is blocked"),
        (r"(^|[;&|]\s*)(sudo|su)\s", "Privilege escalation is blocked"),
        (r"(curl|wget)\s.*\|\s*(ba)?sh", "Remote code execution via pipe is blocked"),
        (r"(^|[;&|]\s*)(eval|exec)\s", "Dynamic code execution is blocked"),
        (r"(^|[;&|]\s*)(dd\s+if=|mkfs|fdisk)", "Disk destructive operation is blocked"),
        (r"chmod\s+777", "chmod 777 is blocked"),
        (r"git\s+push\s.*--force(?!-with-lease)", "git push --force is blocked"),
        (r"git\s+reset\s.*--hard", "git reset --hard is blocked"),
        (r"git\s+clean\s.*-[a-zA-Z]*f", "git clean -f is blocked"),
    ]
    for pattern, reason in deny_rules:
        if reason == "rm_flags":
            if re.search(pattern, command) and re.search(
                r"\s-[a-zA-Z]*r|--recursive|-[a-zA-Z]*R", command
            ):
                return ("deny", "rm with recursive flags is blocked")
        elif re.search(pattern, command):
            return ("deny", reason)

    # Ask: context-dependent
    ask_rules: list[tuple[str, str]] = [
        (r"git\s+push(\s|$)", "git push modifies remote"),
        (r"git\s+(checkout|switch)\s", "Branch switch may discard uncommitted changes"),
        (r"git\s+rebase(\s|$)", "git rebase rewrites history"),
        (r"git\s+stash\s+(drop|clear|pop|apply)", "git stash mutation"),
        (r"git\s+branch\s+-[dD]", "git branch deletion"),
        (r"git\s+tag\s+-d", "git tag deletion"),
        (r"npm\s+(remove|uninstall)(\s|$)", "npm package removal"),
        (r"(^|[;&|]\s*)kill\s", "Process termination"),
        (r"(^|[;&|]\s*)(ssh|scp)\s", "Remote access"),
        (r"sed\s.*-i", "In-place file modification with sed -i"),
    ]
    for pattern, reason in ask_rules:
        if re.search(pattern, command):
            return ("ask", reason)

    if re.search(r"gh\s+api\s", command) and re.search(
        r"--method\s+(PUT|PATCH|DELETE|POST)", command
    ):
        return ("ask", "gh api with write method")

    return ("passthrough", "")


# --- Logging -------------------------------------------------------------- #


def _build_log_dir() -> Path:
    return Path(
        os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"),
        "copilot",
        "hooks",
        "pre-tool-use-permission",
    )


def _log_decision(
    log_dir: Path,
    ts_ms: int,
    tool_name: str,
    decision: str,
    reason: str,
    cmd: str,
    cwd: str,
) -> None:
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / f"{date.today().isoformat()}.jsonl"
    entry = json.dumps(
        {
            "ts": ts_ms,
            "tool": tool_name,
            "decision": decision,
            "reason": reason,
            "cmd": cmd,
            "cwd": cwd,
        },
        ensure_ascii=False,
    )
    with open(log_file, "a") as f:
        f.write(entry + "\n")


# --- Main ----------------------------------------------------------------- #


def main() -> None:
    data = json.loads(sys.stdin.read())
    tool_name: str = data.get("toolName", "")
    tool_args = data.get("toolArgs", "")
    ts_ms = int(data.get("timestamp", 0))
    cwd: str = data.get("cwd", "")
    home_dir = os.environ.get("HOME", "")

    command = parse_command(tool_name, tool_args)
    decision, reason = evaluate(tool_name, command, home_dir)

    log_dir = _build_log_dir()
    if decision != "exit":
        _log_decision(log_dir, ts_ms, tool_name, decision, reason, command, cwd)

    if decision == "allow":
        print('{"permissionDecision":"allow"}')
    elif decision == "deny":
        print(json.dumps({"permissionDecision": "deny", "permissionDecisionReason": reason}))
    elif decision == "ask":
        print(json.dumps({"permissionDecision": "ask", "permissionDecisionReason": reason}))
    # passthrough and exit: no output


if __name__ == "__main__":
    main()
