return {
  "stevearc/oil.nvim",
  config = function()
    -- Initialize the oil plugin with custom configurations
    require("oil").setup({
      -- Disable the default keymaps provided by oil.nvim
      use_default_keymaps = false,

      -- Define custom key mappings for various file and directory actions within oil
      keymaps = {
        ["H"] = "actions.toggle_hidden",  -- Toggle visibility of hidden files/directories
        ["<A-t>"] = "actions.select_tab",  -- Open the selected entry in a new tab
        ["<A-v>"] = "actions.select_vsplit",  -- Open the selected entry in a vertical split
        ["<A-r>"] = "actions.refresh",  -- Refresh the current oil view
        ["<A-x>"] = "actions.select_split",  -- Open the selected entry in a horizontal split
        ["`"] = "actions.cd",  -- Change the directory to the selected entry
        ["~"] = "actions.tcd",  -- Change the tab's working directory to the selected entry
        ["gs"] = "actions.change_sort",  -- Change the sorting method of the entries
        ["gx"] = "actions.open_external",  -- Open the selected entry with an external program
        ["-"] = "actions.parent",  -- Navigate to the parent directory
        ["_"] = "actions.open_cwd",  -- Open the current working directory
        ["<C-c>"] = "actions.close",  -- Close the oil window
        ["<C-p>"] = "actions.preview",  -- Preview the selected entry
        ["g?"] = "actions.show_help",  -- Show help for oil key mappings and commands
        ["<CR>"] = "actions.select",  -- Select the entry under the cursor
        ["g\\"] = "actions.toggle_trash",  -- Toggle moving deleted files to trash or deleting permanently
      },
    })
    -- Set a Neovim keymap for navigating to the parent directory using oil
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory with oil" })
  end,
}
