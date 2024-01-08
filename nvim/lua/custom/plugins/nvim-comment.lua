local vim = vim

return {
    'terrortylor/nvim-comment',
    config = function()
        require('nvim_comment').setup({
            create_mappings = true,
        })
        vim.keymap.set("n", "<leader>c", ":CommentToggle<CR>", { noremap = true })
        vim.keymap.set("v", "<leader>c", ":CommentToggle<CR>", { noremap = true })
    end
}
