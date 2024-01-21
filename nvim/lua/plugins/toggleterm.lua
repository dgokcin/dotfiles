return {
    -- amongst your other plugins
    {'akinsho/toggleterm.nvim',
    version = "*",
    config = true},
    vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { noremap = true, silent = true, desc = "Toggle Terminal" })
  }