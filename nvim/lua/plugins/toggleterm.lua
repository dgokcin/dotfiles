return {
  -- amongst your other plugins
  { "akinsho/toggleterm.nvim", version = "*", event = "VeryLazy", config = true },
  vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { noremap = true, silent = true, desc = "Toggle Terminal" }),
}

