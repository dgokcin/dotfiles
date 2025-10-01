return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<C-b>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer NvimTree (root dir)" },
    },
    config = function()
      local status_ok, tree = pcall(require, "nvim-tree")
      local api = require("nvim-tree.api")

      if not status_ok then
        return
      end

      local function my_on_attach(bufnr)
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "\\", api.node.open.vertical, opts("Open: Vertical Split"))
        vim.keymap.set("n", "-", api.node.open.horizontal, opts("Open: Horizontal Split"))
      end

      tree.setup({
        on_attach = my_on_attach,
        view = {
          adaptive_size = true,
        },
        git = {
          enable = false,
          ignore = false,
          timeout = 500,
        },
      })

      -- Override the existing <C-b> mapping
      vim.keymap.set(
        "n",
        "<C-b>",
        "<cmd>NvimTreeToggle<CR>",
        { noremap = true, silent = true, desc = "Toggle file explorer" }
      )

      -- Keep <leader>e as an alternative
      vim.keymap.set(
        "n",
        "<leader>e",
        "<cmd>NvimTreeToggle<CR>",
        { noremap = true, silent = true, desc = "Explorer NvimTree (root dir)" }
      )

      -- Focus to current file
      vim.keymap.set("n", "<leader>nf", ":NvimTreeFindFile!<CR>", { desc = "NvimTree: focus current file & set root" })
    end,
  },
}

