-- L3MON4D3/LuaSnip
-- see: <https://github.com/L3MON4D3/LuaSnip>
--
-- Snippet管理プラグイン

return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",                -- follow latest release.
  build = "make install_jsregexp", -- install jsregexp (optional!).
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load(
      {
        paths = {
          "./snippets",
          "./snippets-private",
        },
      }
    )
  end,
}