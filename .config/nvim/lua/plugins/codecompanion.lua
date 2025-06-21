-- olimorris/codecompanion.nvim
-- see: <https://codecompanion.olimorris.dev/>
--
-- streamlines how you develop with LLMs, in Neovim.

return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  cmd = {
    "CodeCompanion",
    "CodeCompanionAction",
    "CodeCompanionChat",
  },
  opts = {
    strategies = {
      chat = {
        adapter = "copilot",
        roles = {
          llm = function(adapter)
            return "  CodeCompanion (" .. adapter.formatted_name .. ")"
          end,
          user = "  Me",
        },
      },
      inline = {
        adapter = "copilot",
      },
    },
    language = "Japanese",
    display = {
      chat = {
        auto_scroll = false,
      },
    },
    adapters = {
      copilot = function()
        -- 既定のcopilotアダプタをベースにcopilot adapterを更新
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "gpt-4.1",
            },
          },
        })
      end,
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true
        }
      }
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "codecompanion" },
      },
      ft = { "markdown", "codecompanion" },
    },
    "ravitemer/mcphub.nvim",
  },
}
