return {
  "mg979/vim-visual-multi",
  branch = "master",
  vscode = "true",
  event = { "BufReadPost", "BufEnter" },
  init = function()
    vim.g.VM_maps = {
      ["Add Cursor Down"] = "<M-j>",
      ["Add Cursor Up"] = "<M-k>",
    }
  end,
}
