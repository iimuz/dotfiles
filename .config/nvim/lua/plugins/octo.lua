-- pwntester/octo.nvim
-- see: <https://github.com/pwntester/octo.nvim>
--
-- GitHubの操作を行う

-- vscodeから呼び出す場合は利用しない
local condition = vim.g.vscode == nil

return {
  "pwntester/octo.nvim",
  cond = condition,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require("octo").setup {
      mappings_disable_default = true, -- defaultのショートカットキーは無効化
    }

    -- Telescope用検索コマンド
    local set = vim.keymap.set
    -- issue関連
    set(
      "n",
      "<Plug>octo.issue.list",
      "<cmd>Octo issue list<CR>",
      { desc = "⭐︎Octo: List issues." }
    )
    set(
      "n",
      "<Plug>octo.issue.search",
      "<cmd>Octo issue search<CR>",
      { desc = "Octo: Live issue search." }
    )
    set(
      "n",
      "<Plug>octo.issue.reload",
      "<cmd>Octo issue reload<CR>",
      { desc = "Octo: Reload issue." }
    )
    set(
      "n",
      "<Plug>octo.issue.browser",
      "<cmd>Octo issue rowser<CR>",
      { desc = "Octo: Open current issue in the browser." }
    )
    set(
      "n",
      "<Plug>octo.issue.url",
      "<cmd>Octo issue url<CR>",
      { desc = "Octo: Copies the URL of the current issue to the system clipboard." }
    )
    -- PR関連
    set(
      "n",
      "<Plug>octo.pr.list",
      "<cmd>Octo pr list<CR>",
      { desc = "⭐︎Octo: List PRs." }
    )
    set(
      "n",
      "<Plug>octo.pr.search",
      "<cmd>Octo pr search<CR>",
      { desc = "Octo: Live PR search." }
    )
    set(
      "n",
      "<Plug>octo.pr.checkout",
      "<cmd>Octo pr checkout<CR>",
      { desc = "⭐︎Octo: Checkout PR." }
    )
    set(
      "n",
      "<Plug>octo.pr.commits",
      "<cmd>Octo pr commits<CR>",
      { desc = "Octo: List all PR commits." }
    )
    set(
      "n",
      "<Plug>octo.pr.diff",
      "<cmd>Octo pr diff<CR>",
      { desc = "Octo: Show PR diff." }
    )
    set(
      "n",
      "<Plug>octo.pr.checks",
      "<cmd>Octo pr checks<CR>",
      { desc = "Octo: Show the status of all checks run on the PR." }
    )
    set(
      "n",
      "<Plug>octo.pr.reload",
      "<cmd>Octo pr reload<CR>",
      { desc = "Octo: Reload PR." }
    )
    set(
      "n",
      "<Plug>octo.pr.browser",
      "<cmd>Octo pr browser<CR>",
      { desc = "Octo: Open current PR in the browser." }
    )
    set(
      "n",
      "<Plug>octo.pr.url",
      "<cmd>Octo pr url<CR>",
      { desc = "Octo: Copies the URL of the current PR to the system clipboard." }
    )
    -- リポジトリ関連
    set(
      "n",
      "<Plug>octo.repo.rowser",
      "<cmd>Octo repo browser<CR>",
      { desc = "Octo: Open current repo in the browser." }
    )
    set(
      "n",
      "<Plug>octo.repo.url",
      "<cmd>Octo repo url<CR>",
      { desc = "Octo: Copies the URL of the current repository to the system clipboard." }
    )
    -- gist
    set(
      "n",
      "<Plug>octo.gist.list",
      "<cmd>Octo gist list<CR>",
      { desc = "Octo: List user gists." }
    )
    -- comment
    set(
      "n",
      "<Plug>octo.comment.add",
      "<cmd>Octo comment add<CR>",
      { desc = "⭐︎Octo: Add a new comment." }
    )
    set(
      "n",
      "<Plug>octo.comment.delete",
      "<cmd>Octo comment delete<CR>",
      { desc = "⭐︎Octo: Delete a comment." }
    )
    -- thread
    set(
      "n",
      "<Plug>octo.thread.resolve",
      "<cmd>Octo thread resolve<CR>",
      { desc = "⭐︎Octo: Mark a review thread as resolved." }
    )
    set(
      "n",
      "<Plug>octo.thread.unresolve",
      "<cmd>Octo thread unresolve<CR>",
      { desc = "Octo: Mark a review thread as unresolve." }
    )
    -- Review
    set(
      "n",
      "<Plug>octo.review.start",
      "<cmd>Octo review start<CR>",
      { desc = "⭐︎Octo: Start a new review." }
    )
    set(
      "n",
      "<Plug>octo.review.submit",
      "<cmd>Octo review submit<CR>",
      { desc = "⭐︎Octo: Submit the review." }
    )
    set(
      "n",
      "<Plug>octo.review.resume",
      "<cmd>Octo review resume<CR>",
      { desc = "⭐︎Octo: Edit a pending review for current PR." }
    )
    set(
      "n",
      "<Plug>octo.review.discard",
      "<cmd>Octo review discard<CR>",
      { desc = "Octo: Deletes a pending review for current PR if any." }
    )
    set(
      "n",
      "<Plug>octo.review.comments",
      "<cmd>Octo review comments<CR>",
      { desc = "⭐︎Octo: View pending review comments." }
    )
    set(
      "n",
      "<Plug>octo.review.close",
      "<cmd>Octo review close<CR>",
      { desc = "⭐︎Octo: Close the review window and return to the PR." }
    )
  end
}
