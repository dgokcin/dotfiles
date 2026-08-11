return {
  "kylechui/nvim-surround",
  version = "*",
  vscode = true,
  keys = {
    { "<C-g>s", mode = "i", desc = "surround insert" },
    { "<C-g>S", mode = "i", desc = "surround insert line" },
    { "ys", mode = "n", desc = "surround add" },
    { "yss", mode = "n", desc = "surround add cur line" },
    { "yS", mode = "n", desc = "surround add line" },
    { "ySS", mode = "n", desc = "surround add cur line (block)" },
    { "S", mode = "v", desc = "surround visual" },
    { "gS", mode = "v", desc = "surround visual line" },
    { "ds", mode = "n", desc = "surround delete" },
    { "cs", mode = "n", desc = "surround change" },
    { "cS", mode = "n", desc = "surround change line" },
  },
  config = function()
    require("nvim-surround").setup()
  end,
}
