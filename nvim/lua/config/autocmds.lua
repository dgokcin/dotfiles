-- Disable auto-comment insertion
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- Disable auto-comment insertion
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })

        -- Set foldcolumn to 0
        vim.opt_local.foldcolumn = "0"
    end,
})

-- Remember cursor position when reopening a file
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})