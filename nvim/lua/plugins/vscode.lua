if not vim.g.vscode then
    return {}
  end

  local enabled = {
    "flit.nvim",
    "lazy.nvim",
    "leap.nvim",
    "nvim-treesitter",
    "nvim-treesitter-textobjects",
    "nvim-ts-context-commentstring",
    "ts-comments.nvim",
    "vim-repeat",
    "yanky.nvim",
    "LazyVim",
  }

  local Config = require("lazy.core.config")
  Config.options.checker.enabled = false
  Config.options.change_detection.enabled = false
  Config.options.defaults.cond = function(plugin)
    return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimKeymapsDefaults",
    callback = function()
      -- Undo/Redo Correction for VSCode
      vim.keymap.set("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>")
      vim.keymap.set("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>")

      -- Toggle Terminal
      vim.keymap.set("n", "<leader>t", "<Cmd>call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>")

      -- VSCode-specific keymaps for search and navigation
      vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
      vim.keymap.set("n", "<leader>/", [[<cmd>call VSCodeNotify('workbench.action.findInFiles')<cr>]])
      vim.keymap.set("n", "<leader>ss", [[<cmd>call VSCodeNotify('workbench.action.gotoSymbol')<cr>]])

      -- Tab navigation for VSCode
      vim.keymap.set("n", "<S-h>", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
      vim.keymap.set("n", "<S-l>", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")

      -- Toggle Primary Sidebar Like nvim-tree
      vim.keymap.set("n", "<C-b>", "<Cmd>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<CR>")
      vim.keymap.set("n", "<leader>e", "<Cmd>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<CR>")

      -- Disable convert to uppercase and lowercase in visual mode
      vim.keymap.set('v', 'u', '<Nop>', { noremap = true, silent = true })
      vim.keymap.set('v', 'U', '<Nop>', { noremap = true, silent = true })
    end,
  })

  return {
    {
      "LazyVim/LazyVim",
      config = function(_, opts)
        opts = opts or {}
        -- disable the colorscheme
        opts.colorscheme = function() end
        require("lazyvim").setup(opts)
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = { highlight = { enable = false } },
    },
  }