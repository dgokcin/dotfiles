-- Inspired from https://www.reddit.com/r/neovim/comments/16ikt0q/telescope_live_grep_search_some_hidden_files/
-- TODO: the live grep is ignoring some files where it shouldn't.

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
  },

  config = function()
    local telescope = require("telescope")
    telescope.setup({
      pickers = {
        live_grep = {
          file_ignore_patterns = { "node_modules/", ".git/", ".venv/" },
          additional_args = { "--hidden" },
        },
        grep_string = {
          file_ignore_patterns = { "node_modules/", ".git/", ".venv/" },
          additional_args = { "--hidden" },
        },
        find_files = {
          file_ignore_patterns = { "node_modules/", ".git/", ".venv/" },
          hidden = true,
          case_mode = "ignore_case",
        },
      },
    })
  end,
}
