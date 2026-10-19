-- Tab management

local M = {}

-- 'tabline' の `%!` から呼ばれる。タブが 1 つのときは showtabline の既定値で非表示になる
function M.tabline()
	local current = vim.fn.tabpagenr()
	local parts = {}
	for n = 1, vim.fn.tabpagenr("$") do
		local buflist = vim.fn.tabpagebuflist(n)
		local name = vim.fn.fnamemodify(vim.fn.bufname(buflist[vim.fn.tabpagewinnr(n)]), ":t")
		if name == "" then
			name = "[No Name]"
		end
		local modified = false
		for _, buf in ipairs(buflist) do
			-- picker の入力欄など、保存先の無いバッファの変更は数えない
			modified = modified or (vim.bo[buf].buftype == "" and vim.bo[buf].modified)
		end
		table.insert(parts, "%" .. n .. "T")
		table.insert(parts, n == current and "%#TabLineSel#" or "%#TabLine#")
		-- '%' は書式の特殊文字なので 2 重にして 1 文字として表示させる
		table.insert(parts, " " .. n .. " " .. name:gsub("%%", "%%%%") .. (modified and " +" or "") .. " ")
	end
	table.insert(parts, "%T%#TabLineFill#")
	return table.concat(parts)
end

function M.setup()
	vim.opt.tabline = "%!v:lua.require'tab'.tabline()"

	-- キーマッピング
	local set = vim.keymap.set
	set("n", "<Leader>Bn", "<cmd>tabnext<CR>", { desc = "⭐︎Tab: Move next tab." })
	set("n", "<Leader>BN", "<cmd>tabprevious<CR>", { desc = "⭐︎Tab: Move previous tab." })
	set("n", "<Leader>Bo", "<cmd>tabnew<CR>", { desc = "⭐︎Tab: Open a new tab." })
	set("n", "<Leader>Bx", "<cmd>tabclose<CR>", { desc = "⭐︎Tab: Close tab." })
end

return M
