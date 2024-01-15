return {
    'vscode-neovim/vscode-multi-cursor.nvim',
    event = 'VeryLazy',
    vscode = 'true',
    cond = not not vim.g.vscode,
    opts = {},
  }