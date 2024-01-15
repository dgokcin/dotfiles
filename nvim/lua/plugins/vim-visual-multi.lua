return {
  'mg979/vim-visual-multi',
  branch = 'master',
  event = 'BufReadPost',
  cond = not vim.g.vscode,
  init = function()
    -- vim.g.VM_maps = {
    --   ['Add Cursor Down'] = '<M-C-Down>',
    --   ['Select Cursor Up'] = '<M-C-Up>',
  -- }
  end,
}
