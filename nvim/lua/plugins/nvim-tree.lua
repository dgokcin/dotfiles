return {
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        },
        event = 'VeryLazy',
        config = function()
            local status_ok, tree = pcall(require, 'nvim-tree')
            local api = require('nvim-tree.api')

            if not status_ok then
                return
            end

            local function my_on_attach(bufnr)
                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set('n', '|',   api.node.open.vertical,              opts('Open: Vertical Split'))
                vim.keymap.set('n', '-',   api.node.open.horizontal,            opts('Open: Horizontal Split'))
            end

            tree.setup({
                on_attach = my_on_attach,
                view = {
                    adaptive_size = true,
                },
                git = {
                    enable = true,
                    ignore = false,
                    timeout = 500,
                },
            })

            -- Toggle NvimTree globally with <C-b>
            vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
        end
    },
}
