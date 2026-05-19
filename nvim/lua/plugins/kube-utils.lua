return {
  {
    "h4ckm1n-dev/kube-utils-nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    lazy = true,
    event = "VeryLazy",
    config = function()
      require("kube-utils-nvim").setup()
    end,
    keys = {
      { "<leader>kkK", "<cmd>OpenK9s<CR>", desc = "Open K9s" },
      { "<leader>kkk", "<cmd>OpenK9sSplit<CR>", desc = "Split View K9s" },
    },
  },
}
