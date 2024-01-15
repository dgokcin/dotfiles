return {
  "goolord/alpha-nvim",
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    local logo = [[
      ¯\_(ツ)_/¯
    ]]
    dashboard.section.header.val = vim.split(logo, "\n")
    -- stylua: ignore
  end,
}
