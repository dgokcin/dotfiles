return {
  "kylechui/nvim-surround",
  version = "*",
  event = "BufRead",
  vscode = "true",
  config = function()
    require("nvim-surround").setup({
      keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "<leader>S",
          normal_cur = "<leader>SS",
          normal_line = "<leader>S_",
          normal_cur_line = "<leader>S__",
          visual = "<leader>S",
          visual_line = "<leader>S_",
          delete = "ds",
          change = "cs",
      },
  })
    if not vim.g.vscode then
      -- Setup which-key descriptions for nvim-surround keymaps
      local wk = require("which-key")
      local mappings = {
        { mode = { "n", "v" } },
        { "<leader>S", group = "surround" },
        { "<leader>Sa", group = "around" },
        { "<leader>Si", group = "inside" },
        { '<leader>Sa"', desc = "Surround around double quotes" },
        { "<leader>Sa'", desc = "Surround around single quotes" },
        { "<leader>Sa(", desc = "Surround around parentheses" },
        { "<leader>Sa<", desc = "Surround around angle brackets" },
        { "<leader>SaW", desc = "Surround around WORD" },
        { "<leader>Sa[", desc = "Surround around brackets" },
        { "<leader>Sa`", desc = "Surround around backticks" },
        { "<leader>Sap", desc = "Surround around paragraph" },
        { "<leader>Sas", desc = "Surround around sentence" },
        { "<leader>Sat", desc = "Surround around tag block" },
        { "<leader>Saw", desc = "Surround around word" },
        { "<leader>Sa{", desc = "Surround around braces" },
        { '<leader>Si"', desc = "Surround inside double quotes" },
        { "<leader>Si'", desc = "Surround inside single quotes" },
        { "<leader>Si(", desc = "Surround inside parentheses" },
        { "<leader>Si<", desc = "Surround inside angle brackets" },
        { "<leader>SiW", desc = "Surround inside WORD" },
        { "<leader>Si[", desc = "Surround inside brackets" },
        { "<leader>Si`", desc = "Surround inside backticks" },
        { "<leader>Sip", desc = "Surround inside paragraph" },
        { "<leader>Sis", desc = "Surround inside sentence" },
        { "<leader>Sit", desc = "Surround inside tag block" },
        { "<leader>Siw", desc = "Surround inside word" },
        { "<leader>Si{", desc = "Surround inside braces" },
      }
      wk.add(mappings)
    end
  end,
}
