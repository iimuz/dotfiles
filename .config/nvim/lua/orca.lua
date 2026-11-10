-- Orcaのエディタで今のファイルを開く

local M = {}

local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN)
end

function M.worktree_id()
	local id = vim.env.ORCA_WORKTREE_ID
	if id == nil or id == "" or vim.fn.executable("orca") ~= 1 then
		return nil
	end
	return id
end

function M.worktree_root(worktree_id)
	local _, finish = worktree_id:find("::", 1, true)
	if finish == nil then
		return nil
	end
	return worktree_id:sub(finish + 1)
end

function M.contains(root, path)
	return path == root or vim.startswith(path, root .. "/")
end

function M.run(args, on_success)
	vim.system(vim.list_extend({ "orca" }, args), { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				warn("orca failed: " .. (result.stderr or ""))
			elseif on_success then
				on_success(result.stdout or "")
			end
		end)
	end)
end

function M.open_file(path)
	local id = M.worktree_id()
	if id == nil then
		warn("Not inside an Orca terminal.")
		return
	end

	-- /tmp と /private/tmp のように、片方だけ実体のパスのことがある
	local root = M.worktree_root(id)
	local real_path = vim.uv.fs_realpath(path) or path
	local real_root = root and (vim.uv.fs_realpath(root) or root)
	if real_root == nil or not M.contains(real_root, real_path) then
		warn("File is outside this Orca worktree.")
		return
	end

	M.run({ "file", "open", path, "--worktree", "id:" .. id })
end

function M.setup()
	vim.keymap.set("n", "<Leader>mo", function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" or vim.uv.fs_stat(path) == nil then
			warn("Buffer has no file on disk.")
			return
		end
		M.open_file(path)
	end, { desc = "Orca: Open current file in Orca editor." })
end

return M
