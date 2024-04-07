-- neovimを起動しているプロジェクトルートの設定を読み込むための設定
--
-- neovimを起動している場所をプロジェクトルートとして判定する。
-- プロジェクトルートに.neovimフォルダがあれば、その中にあるinit-project.luaを読み込む。

local cwd = vim.fn.getcwd()
local settings_dir = cwd .. "/.neovim"

-- プロジェクトルートに特定フォルダがなければ何もしない
if vim.fn.isdirectory(settings_dir) ~= 1 then
	return
end

-- プロジェクトルートの特定フォルダに特定ファイルを起点として読み込む
package.path = settings_dir .. "/?.lua;" .. package.path
require("init-project")
