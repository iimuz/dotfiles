-- markdown-preview.nvim
-- see: <https://github.com/selimacerbas/markdown-preview.nvim>
--
-- Preview markdown file.

-- cmux のターミナル内かどうか (notify.sh と同じく CMUX_SURFACE_ID で判定)
local in_cmux = vim.env.CMUX_SURFACE_ID ~= nil

-- BufEnter の follow で start() が再実行されても cmux コマンドを連打しないための直前 URL キャッシュ
local last_opened_url = nil

-- cmux の内蔵ブラウザでプレビュー URL を開く。
-- 同一 workspace 内に既存のプレビュータブがあれば navigate で差し替え、
-- なければ新規タブを開く (cmux browser open はフォーカスを奪わない)。
local function open_in_cmux(url)
    if url == last_opened_url then
        return
    end
    local cmux_bin = vim.env.CMUX_BUNDLED_CLI_PATH or "cmux"
    local ok, err = pcall(function()
        local tree_result = vim.system(
            { cmux_bin, "tree", "--json", "--workspace", vim.env.CMUX_WORKSPACE_ID },
            { text = true }
        ):wait()
        assert(tree_result.code == 0, tree_result.stderr)
        local tree = vim.json.decode(tree_result.stdout)
        local preview_ref = nil
        for _, win in ipairs(tree.windows or {}) do
            for _, workspace in ipairs(win.workspaces or {}) do
                for _, pane in ipairs(workspace.panes or {}) do
                    for _, surface in ipairs(pane.surfaces or {}) do
                        if
                            surface.type == "browser"
                            and type(surface.url) == "string"
                            and surface.url:match("^http://127%.0%.0%.1:%d+/%?t=")
                        then
                            preview_ref = surface.ref
                        end
                    end
                end
            end
        end
        local cmd
        if preview_ref then
            cmd = { cmux_bin, "browser", preview_ref, "navigate", url }
        else
            cmd = { cmux_bin, "browser", "open", url }
        end
        local open_result = vim.system(cmd, { text = true }):wait()
        assert(open_result.code == 0, open_result.stderr)
    end)
    if not ok then
        vim.notify("MarkdownPreview: cmux open failed: " .. tostring(err), vim.log.levels.WARN)
        return
    end
    last_opened_url = url
end

return {
    "selimacerbas/markdown-preview.nvim",
    lazy = true,
    enabled = true,
    cmd = { "MarkdownPreview", "MarkdownPreviewRefresh", "MarkdownPreviewStop" },
    ft = { "markdown" },
    dependencies = { "selimacerbas/live-server.nvim" },
    config = function()
        local opts = {
            scroll_sync = false, -- iamcco 版の disable_sync_scroll = 1 に相当
        }
        if in_cmux then
            -- cmux 内では workspace ごとにプレビューを分離するため multi にし、
            -- 既定のブラウザ起動を止めて内蔵ブラウザで開く (issue #300)
            opts.instance_mode = "multi"
            opts.open_browser = false
            opts.hooks = { on_start = open_in_cmux }
        end
        require("markdown_preview").setup(opts)
        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("MarkdownPreviewFollow", { clear = true }),
            callback = function(ev)
                if vim.bo[ev.buf].filetype ~= "markdown" then
                    return
                end
                local mp = require("markdown_preview")
                if mp._server_instance or mp._takeover_port then
                    mp.start()
                end
            end,
            desc = "MarkdownPreview: Follow active markdown buffer.",
        })
    end,
    keys = {
        { "<Leader>ms", "<cmd>MarkdownPreview<CR>", desc = "MarkdownPreview: Start markdown preview." },
        { "<Leader>mq", "<cmd>MarkdownPreviewStop<CR>", desc = "MarkdownPreview: Stop markdown preview." },
        {
            "<Leader>my",
            function()
                local m = require("markdown_preview")
                if not (m._server_instance and m._token) then
                    vim.notify("markdown-preview: server not running", vim.log.levels.WARN)
                    return
                end
                local url = ("http://127.0.0.1:%d/?t=%s"):format(m._server_instance.port, m._token)
                vim.fn.setreg("+", url)
                vim.notify("MarkdownPreview URL copied: " .. url, vim.log.levels.INFO)
            end,
            desc = "MarkdownPreview: Yank preview URL with token.",
        },
        {
            "<Leader>mt",
            function()
                local m = require("markdown_preview")
                m.config.scroll_sync = not m.config.scroll_sync
                local state = m.config.scroll_sync and "on" or "off"
                vim.notify("MarkdownPreview scroll sync: " .. state, vim.log.levels.INFO)
            end,
            desc = "MarkdownPreview: Toggle scroll sync.",
        },
    },
}
