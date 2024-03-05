return {
  "dgokcin/fast-cursor-move.nvim",
  event = "BufRead",
  vscode = true,
  config = function()
      vim.defer_fn(function()
          require("fast-cursor-move").setup({
              enable_acceleration = false,
          })
      end, 500)
  end,
}