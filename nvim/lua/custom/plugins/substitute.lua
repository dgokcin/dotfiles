return {
    "gbprod/substitute.nvim",
    keys = {
      "s",
      "ss",
      "S",
      "<leader>s",
      "<leader>ss",
      "sx",
      "sxx",
      "sxc",
      { "s", mode = "x" },
      { "<leader>s", mode = "x" },
      { "X", mode = "x" },
    },
    -- opts = {},
    config = function()
      require("substitute").setup({})
      vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
      vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
      vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
      vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })
      vim.keymap.set("n", "<leader>s", require("substitute.range").operator, { noremap = true })
      vim.keymap.set("x", "<leader>s", require("substitute.range").visual, { noremap = true })
      vim.keymap.set("n", "<leader>ss", require("substitute.range").word, { noremap = true })
      -- Exchange
      vim.keymap.set("n", "sx", require("substitute.exchange").operator, { noremap = true })
      vim.keymap.set("n", "sxx", require("substitute.exchange").line, { noremap = true })
      vim.keymap.set("x", "sx", require("substitute.exchange").visual, { noremap = true })
      vim.keymap.set("n", "sxc", require("substitute.exchange").cancel, { noremap = true })
    end,
  }