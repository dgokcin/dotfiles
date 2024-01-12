-- Keymaps for better default experience
-- See `:help vim.keymap.set()`

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Clear search highlight with two <esc>
vim.keymap.set('n', '<Esc><Esc>', ':noh<CR>', { noremap = true, silent = true })

-- Maps ctrl + a to select all
vim.keymap.set('n', '<C-A>', 'ggVG', { noremap = true, desc = 'Select All'})

-- Maps <leader>w to visual in word
vim.keymap.set('n', '<leader>w', 'viw', { noremap = true })

-- Makes <Tab> and <S-Tab> move to beginning/end of line in normal mode
vim.keymap.set('n', '<Tab>', '$', { noremap = true })
vim.keymap.set('n', '<S-Tab>', '^', { noremap = true })

-- Fix indentation in entire file
vim.keymap.set('n', '_', 'gg=G``zz', { noremap = true })
vim.keymap.set('v', '_', 'gg=G``zz', { noremap = true })

-- Maps d and x to black-hole registry
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('n', 'X', '"_X', { noremap = true })

-- Maps leader de to cut
vim.keymap.set('n', '<leader>d', '"_d', { noremap = true })
vim.keymap.set('n', '<leader>D', '"_D', { noremap = true })
vim.keymap.set('v', '<leader>d', '"_d', { noremap = true })

-- Move between windows with shift + hjkl
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })

-- Paste without yanking
vim.keymap.set('v', 'p', '"_dP', { noremap = true })

-- Insert blank line above/below without losing cursor position
vim.keymap.set('n', '<Enter>', function() require('utils').insert_blank_line_below() end, { noremap = true, silent = true })
vim.keymap.set('n', '<BS>', function() require('utils').insert_blank_line_above() end, { noremap = true, silent = true })

-- Move current line 1 line down in v-line mode and remember cursor position with gv
vim.api.nvim_set_keymap("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Warrior Mode
vim.keymap.set('n', '<Up>', '<Nop>', { noremap = true })
vim.keymap.set('n', '<Down>', '<Nop>', { noremap = true })
vim.keymap.set('n', '<Left>', '<Nop>', { noremap = true })
vim.keymap.set('n', '<Right>', '<Nop>', { noremap = true })
