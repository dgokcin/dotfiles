return {
  {
    "folke/tokyonight.nvim",
    config = function()
      require('tokyonight').setup({
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      })

      -- Override the Visual highlight group after Vim starts up
      vim.cmd [[
        augroup MyColors
          autocmd!
          autocmd VimEnter * highlight Visual guibg=Gray guifg=#ffffff
        augroup END
      ]]
    end,
    opts = {
      -- Your existing options
    },
  }
}