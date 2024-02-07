-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
local vim = vim

return {
  "gbprod/stay-in-place.nvim",
  event = "BufRead",
  vscode = "true",
  config = function()
    local stayinplace = require("stay-in-place") -- Importing the module
    -- Custom key mappings for stay-in-place

    vim.keymap.set("n", ">", stayinplace.shift_right, { noremap = false, expr = true })
    vim.keymap.set("n", "<", stayinplace.shift_left, { noremap = false, expr = true })
    vim.keymap.set("n", "=", stayinplace.filter, { noremap = true, expr = true })

    vim.keymap.set("n", ">", stayinplace.shift_right_line, { noremap = true })
    vim.keymap.set("n", "<", stayinplace.shift_left_line, { noremap = true })
    vim.keymap.set("n", "=", stayinplace.filter_line, { noremap = true })

    vim.keymap.set("x", ">", stayinplace.shift_right_visual, { noremap = true })
    vim.keymap.set("x", "<", stayinplace.shift_left_visual, { noremap = true })
    vim.keymap.set("x", "=", stayinplace.filter_visual, { noremap = true })

    stayinplace.setup({
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      set_keymaps = false,
    })
  end,
}
