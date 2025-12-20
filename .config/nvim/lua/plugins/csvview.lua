-- csvview.nvim
-- see: <https://github.com/hat0uma/csvview.nvim>
--
-- csvファイルの表示と編集

return {
	"hat0uma/csvview.nvim",
	---@module "csvview"
	---@type CsvView.Options
	opts = {
		parser = { comments = { "#", "//" } },
	},
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	keys = {
		{
			"<Leader>Se",
			"<cmd>CsvViewEnable delimiter=, display_mode=border header_lnum=1<CR>",
			desc = "CSVView: Enable.",
		},
		{ "<Leader>Sd", "<cmd>CsvViewDisable<CR>", desc = "CSVView: Enable." },
	},
}
