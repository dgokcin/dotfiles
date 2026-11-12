return {
  "mg979/vim-visual-multi",
  branch = "master",
  vscode = "true",
  event = { "BufReadPost", "BufEnter" },
  init = function()
    vim.g.VM_maps = {
      -- alt+j/k belong to herdr pane focus.
      ["Add Cursor Down"] = "<M-J>",
      ["Add Cursor Up"] = "<M-K>",
    }
  end,
}
