return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local c = opts.sections.lualine_c
    c[#c] = { LazyVim.lualine.pretty_path({ length = 0 }) }
  end,
}
