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
      set_keymaps = false,
    })
  end,
}

