-- markdown-preview.nvim
-- see: <https://github.com/selimacerbas/markdown-preview.nvim>
--
-- Preview markdown file.

return {
    "selimacerbas/markdown-preview.nvim",
    lazy = true,
    enabled = true,
    cmd = { "MarkdownPreview", "MarkdownPreviewRefresh", "MarkdownPreviewStop" },
    ft = { "markdown" },
    dependencies = { "selimacerbas/live-server.nvim" },
    config = function()
        require("markdown_preview").setup({
            scroll_sync = false, -- iamcco 版の disable_sync_scroll = 1 に相当
        })
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
