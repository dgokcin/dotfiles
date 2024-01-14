return {
    'kylechui/nvim-surround',
    version = '*',
    event = 'BufRead',
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
}
