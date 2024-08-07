return {
  "kylechui/nvim-surround",
  version = "*",
  event = "BufRead",
  vscode = "true",
  config = function()
    require("nvim-surround").setup({})
    if not vim.g.vscode then
      -- Setup which-key descriptions for nvim-surround keymaps
      local wk = require("which-key")
      local mappings = {
        { mode = { "n", "v" } },
        { "ys",               group = "surround" },
        { "ysa",              group = "around" },
        { 'ysa"',             desc = "Surround around double quotes" },
        { "ysa'",             desc = "Surround around single quotes" },
        { "ysa(",             desc = "Surround around parentheses" },
        { "ysa<",             desc = "Surround around angle brackets" },
        { "ysaW",             desc = "Surround around WORD" },
        { "ysa[",             desc = "Surround around brackets" },
        { "ysa`",             desc = "Surround around backticks" },
        { "ysap",             desc = "Surround around paragraph" },
        { "ysas",             desc = "Surround around sentence" },
        { "ysat",             desc = "Surround around tag block" },
        { "ysaw",             desc = "Surround around word" },
        { "ysa{",             desc = "Surround around braces" },
        { "ysi",              group = "inside" },
        { 'ysi"',             desc = "Surround inside double quotes" },
        { "ysi'",             desc = "Surround inside single quotes" },
        { "ysi(",             desc = "Surround inside parentheses" },
        { "ysi<",             desc = "Surround inside angle brackets" },
        { "ysiW",             desc = "Surround inside WORD" },
        { "ysi[",             desc = "Surround inside brackets" },
        { "ysi`",             desc = "Surround inside backticks" },
        { "ysip",             desc = "Surround inside paragraph" },
        { "ysis",             desc = "Surround inside sentence" },
        { "ysit",             desc = "Surround inside tag block" },
        { "ysiw",             desc = "Surround inside word" },
        { "ysi{",             desc = "Surround inside braces" },
      }
      wk.add(mappings)
    end
  end,
}
