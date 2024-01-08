return {
  'vscode-neovim/vscode-multi-cursor.nvim',
  config = function()
      cond = not not vim.g.vscode,
      require('vscode-multi-cursor').setup { -- Config is optional
      -- Whether to set default mappings
      default_mappings = true,
      -- If set to true, only multiple cursors will be created without multiple selections
      no_selection = true
    }

      vim.keymap.set({ "n", "x", "i" }, "<C-d>", function()
        require("vscode-multi-cursor").addSelectionToNextFindMatch()

      end)
      vim.keymap.set('n', '<C-n>', 'mciw*<Cmd>nohl<CR>', { remap = true })
  end
}
