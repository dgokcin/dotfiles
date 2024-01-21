return {
  "zbirenbaum/copilot.lua",
  enabled = true,
  cmd = "Copilot",
  event = "VeryLazy",
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      gitcommit = true,
      markdown = true,
      typescript = true,
    },
  },
}
