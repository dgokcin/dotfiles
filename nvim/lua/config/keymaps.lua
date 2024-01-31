-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Clear search highlight with two <esc>
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { noremap = true, silent = true })

-- Maps ctrl + a to select all
vim.keymap.set("n", "<C-A>", "ggVG", { noremap = true, desc = "Select All" })

-- Maps <leader>w to visual in word
vim.keymap.set("n", "<leader>w", "viw", { noremap = true, desc = "Select Word" })

-- Makes <Tab> and <S-Tab> move to beginning/end of line in normal mode
vim.keymap.set("n", "<Tab>", "$", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "^", { noremap = true })

-- Fix indentation in entire file
vim.keymap.set("n", "<leader>cfi", "gg=G``zz", { noremap = true, desc = "Fix indentation in the entire file" })
vim.keymap.set("v", "<leader>cfi", "gg=G``zz", { noremap = true, desc = "Fix indentation in the entire file" })

-- Maps d and x to black-hole registry
vim.keymap.set("n", "x", '"_x', { noremap = true })
vim.keymap.set("n", "X", '"_X', { noremap = true })

-- Escape terminal mode with <C-\\><C-n>
vim.keymap.set("t", "<Esc><leader>", "<C-\\><C-n>", { noremap = true })

-- Maps leader d to cut
vim.keymap.set("n", "<leader>d", '"_d', { noremap = true, desc = "Delete line without yanking" })
vim.keymap.set("n", "<leader>D", '"_D', { noremap = true, desc = "Delete to end of line without yanking" })
vim.keymap.set("v", "<leader>d", '"_d', { noremap = true, desc = "Delete selection without yanking" })

-- Move between windows with shift + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })

-- Paste without yanking
vim.keymap.set("v", "p", '"_dP', { noremap = true })

-- Insert blank line above/below without losing cursor position
vim.keymap.set("n", "<Enter>", "m`o<Esc>``", { noremap = true, silent = true })
vim.keymap.set("n", "<BS>", "m`O<Esc>``", { noremap = true, silent = true })

-- Move current line 1 line down in v-line mode and remember cursor position with gv
vim.api.nvim_set_keymap("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Terminal Mappings
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
vim.keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- tabs
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Toggle NvimTree
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set(
  "n",
  "<leader>e",
  ":NvimTreeToggle<CR>",
  { noremap = true, silent = true, desc = "Explorer NvimTree (root dir)" }
)

-- Remap > back to > in normal mode
-- vim.keymap.set("n", ">", ">", { noremap = true })
-- vim.keymap.set("n", "<", "<", { noremap = true })

-- Warrior Mode
vim.keymap.set("n", "<Up>", "<Nop>", { noremap = true })
vim.keymap.set("n", "<Down>", "<Nop>", { noremap = true })
vim.keymap.set("n", "<Left>", "<Nop>", { noremap = true })
vim.keymap.set("n", "<Right>", "<Nop>", { noremap = true })
