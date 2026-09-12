-- Silence MD013/line-length from markdownlint-cli2 by passing a base config.
local here = vim.fn.resolve(debug.getinfo(1, "S").source:sub(2))
local config = vim.fs.normalize(vim.fs.dirname(here) .. "/../../.markdownlint.yaml")

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", config, "-" },
        },
      },
    },
  },
}
