-- mistweaverco/kulala.nvim
-- see: <https://github.com/mistweaverco/kulala.nvim>
--
-- http client

return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {
      global_keymaps = false,
      kulala_keymaps_prefix = "",
    },
  },
}
