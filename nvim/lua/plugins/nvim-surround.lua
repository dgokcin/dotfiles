return {
  "kylechui/nvim-surround",
  version = "*",
  event = "BufRead",
  vscode = "true",
  config = function()
    require("nvim-surround").setup({})
    -- Setup which-key descriptions for nvim-surround keymaps
    local wk = require("which-key")
    local mappings = {
      ys = {
        name = "+surround",
        ["i"] = {
          name = "+inside",
          ["\""] = "Surround inside double quotes",
          ["'"] = "Surround inside single quotes",
          ["("] = "Surround inside parentheses",
          ["["] = "Surround inside brackets",
          ["{"] = "Surround inside braces",
          ["<"] = "Surround inside angle brackets",
          ["`"] = "Surround inside backticks",
          ["w"] = "Surround inside word",
          ["W"] = "Surround inside WORD",
          ["s"] = "Surround inside sentence",
          ["p"] = "Surround inside paragraph",
          ["t"] = "Surround inside tag block",
        },
        ["a"] = {
          name = "+around",
          ["\""] = "Surround around double quotes",
          ["'"] = "Surround around single quotes",
          ["("] = "Surround around parentheses",
          ["["] = "Surround around brackets",
          ["{"] = "Surround around braces",
          ["<"] = "Surround around angle brackets",
          ["`"] = "Surround around backticks",
          ["w"] = "Surround around word",
          ["W"] = "Surround around WORD",
          ["s"] = "Surround around sentence",
          ["p"] = "Surround around paragraph",
          ["t"] = "Surround around tag block",
        }
      }
    }

    local opts = {
      prefix = "",
      mode = { "n", "v" },  -- Normal and Visual mode
    }
    wk.register(mappings, opts)
  end,
}