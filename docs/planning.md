---
issue: 182
---

# Planning: PR #182 Devcontainer Neovim Setup Analysis

## Goal

Analyze devcontainer startup logs to determine if PR #182 fixes the E492 errors and identify remaining issues.

## Ref

- `docs/reports/2026-04-05-devcontainer-neovim.md`
- `iimuz/dotfiles PR #182` (branch: copilot/fix-nvim-setup-failure)
- `iimuz/dotfiles .devcontainer/post-install.sh`
- `iimuz/dotfiles .config/nvim/lua/lazy-init.lua`

## Steps

- [x] Step 1: Read PR #182 diff and description
- [x] Step 2: Read devcontainer startup log
- [x] Step 3: Read lazy-init.lua and init.lua from PR branch
- [x] Step 4: Cross-reference Neovim version (v0.12.0) with vim.loop deprecation status
- [x] Step 5: Analyze root cause of E492 persistence
- [x] Step 6: Identify other issues in devcontainer log
- [x] Step 7: Document findings and recommendations

## Verify

Log analysis is complete when all findings are documented and actionable items are identified.

## Analysis Results

### PR #182 Fix Status: NOT WORKING

The bootstrap step (`nvim --headless +qa 2>/dev/null || true`) does not resolve the E492 errors. Log lines 962-966 show all three plugin commands still fail:

```
[2026-04-05 00:49:19] [INFO] Setting up Neovim...
Error in command line:
E492: Not an editor command: Lazy! sync
E492: Not an editor command: MasonToolsInstallSync
E492: Not an editor command: TSUpdateSync
```

### Root Cause Analysis

1. `lazy-init.lua` uses `vim.loop.fs_stat()` which is deprecated since Neovim 0.10 and the devcontainer runs Neovim v0.12.0. While `vim.loop` is still an alias in 0.12.0 (not fully removed), deprecation warnings or runtime behavior changes may interfere with headless execution.

2. The bootstrap step redirects stderr to `/dev/null` (`2>/dev/null`), hiding all errors from the first nvim invocation. Any failure in `lazy-init.lua` (git clone failure, Lua error, setup error) is silently swallowed, making diagnosis impossible.

3. If `vim.fn.system({"git", "clone", ...})` fails during bootstrap (e.g., network, permissions, environment), lazy.nvim is never cloned. The code does not check `vim.v.shell_error` after the system call. Subsequent runs find lazy.nvim missing, `require("lazy")` fails, and `:Lazy` command is never registered.

4. Even if lazy.nvim clones successfully, `require("lazy").setup("plugins", opts)` may fail if any plugin spec in `lua/plugins/*.lua` references unavailable modules in headless context.

### Recommendations for PR #182

1. Remove `2>/dev/null` from bootstrap step to enable visibility into errors.
2. Update `lazy-init.lua` to use `(vim.uv or vim.loop).fs_stat()` for Neovim 0.10+ compatibility.
3. Add error checking after `vim.fn.system` clone call (check `vim.v.shell_error`).
4. Consider a more robust bootstrap: clone lazy.nvim directly via shell `git clone` before invoking nvim.

### Other Issues in Devcontainer Log

1. (Low) `mise WARN npm may be required but was not found` (lines 237-274): Expected during first `mise install` before node is available. Resolved on second run.
2. (Low) `mise WARN Failed to resolve tool version list for npm:*` (lines 275-277): Same root cause as above. Resolved on second `mise install`.
3. (Low) `mise Cannot parse Rekor public key` (lines 345, 428): Known mise issue with signature verification. Does not block installation.
4. (Low) `Exit code 1` from dotfiles linking phase (line 980): Codespaces re-links dotfiles after post-install. Exit code 1 likely from pre-existing symlinks. Overall outcome is "success".
5. (Info) cargo-tree-sitter-cli PATH warning (line 942): `mise` manages this path; no user action needed.

## Debt

- lazy-init.lua uses deprecated `vim.loop` API; should migrate to `vim.uv` or `(vim.uv or vim.loop)` pattern.

## Log

- 2026-04-05: Initial analysis. PR #182 bootstrap step does NOT fix E492 errors. Root cause is likely silent failure during `nvim --headless +qa 2>/dev/null`. The `2>/dev/null` hides all diagnostic output.
- 2026-04-05: Confirmed Neovim v0.12.0 in devcontainer. `vim.loop` is deprecated (0.10+) but still available as alias. Not the primary cause but should be updated.
- 2026-04-05: v2 log (after removing 2>/dev/null and adding vim.uv fix) shows same E492 errors. Bootstrap `nvim --headless +qa` produces NO output at all, suggesting init.lua or lazy-init.lua fails silently in headless mode. Changed approach: clone lazy.nvim directly via shell `git clone` in post-install.sh to bypass headless Neovim issues entirely.
- 2026-04-05: v3 log confirms lazy.nvim clone succeeds via shell, but E492 persists. Root cause identified: `base.lua` line 61 has `vim.opt.title = on` where `on` is undefined in Lua (nil). This causes a runtime error in `require("base")` which halts init.lua before `require("lazy-init")` executes. Headless mode suppresses the Lua error output. Fixed to `vim.opt.title = true`.

## Scratchpad

- PR branch: copilot/fix-nvim-setup-failure (sha: 2fcc308)
- Base: master (sha: f265e4f)
- Neovim version in devcontainer: v0.12.0
- lazy-init.lua sha: 94ddb01
- The PR only adds 6 lines (the bootstrap nvim invocation + comments)
- No CI check runs found on the PR
