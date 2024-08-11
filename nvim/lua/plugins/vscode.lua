return {
    "LazyVim/LazyVim",
    vscode = true,
    opts = function(_, opts)
        -- print something so that we know that the plugin is loaded
        print("VSCode plugin loaded")

        -- Set VSCode-specific keymaps after a short delay
        vim.defer_fn(function()
            -- Undo/Redo Correction for VSCode
            vim.keymap.set("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>")
            vim.keymap.set("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>")
            vim.keymap.set("n", "<leader>t", "<Cmd>call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>")

            -- Tab navigation for VSCode
            vim.keymap.set("n", "<S-h>", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
            vim.keymap.set("n", "<S-l>", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
        end, 100)  -- 100ms delay
    end,
}