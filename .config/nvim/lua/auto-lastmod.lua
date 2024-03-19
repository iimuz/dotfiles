-- Markdownファイルのfront matterにあるlastmodを自動で保存日時に書き換える

local function UpdateLastmod()
  local lastmod = vim.fn.strftime("%Y-%m-%dT%H:%M:%S")              -- 現在の日時を取得
  local buf = vim.api.nvim_get_current_buf()                        -- 現在のバッファを取得
  local max_line = 10                                               -- 最大で読み込む行数
  local lines = vim.api.nvim_buf_get_lines(buf, 0, max_line, false) -- 先頭からmax_line行のみ確認する

  -- frontmatterを見つける
  -- ipairsは1から始まる
  local start_line, end_line = nil, nil
  for i, line in ipairs(lines) do
    if start_line ~= nil and line:match("^---$") then
      end_line = i
      break
    end

    if start_line == nil and line:match("^---$") then
      start_line = i
    end
  end
  if end_line == nil then
    end_line = 10
  end

  if start_line and end_line then
    -- lastmodフィールドを見つける
    local lastmod_line = nil
    for i = start_line, end_line do
      if lines[i]:match("^lastmod:.*$") then
        lastmod_line = i
        break
      end
    end

    if lastmod_line then
      local lastmod_str = "lastmod: " .. lastmod .. "+09:00"
      print("Update lastmod: " .. lastmod_str)
      vim.api.nvim_buf_set_lines(buf, lastmod_line - 1, lastmod_line, false, { lastmod_str })
    end
  end
end

-- ファイル保存時にUpdateLastmod()を実行
vim.api.nvim_create_autocmd(
  { "BufWritePost" },
  {
    pattern = { "*.md" },
    callback = UpdateLastmod,
  }
)
