return {
  {
    "saghen/blink.cmp",

    -- v2 lives on main and needs blink.lib. Untagged main has no release
    -- asset to download, so the fuzzy matcher is built locally via cargo.
    branch = "main",
    version = false,
    dependencies = { "saghen/blink.lib" },
    build = function()
      require("blink.cmp").build():pwait(300000)
    end,

    opts = {
      completion = {
        list = {
          selection = { preselect = false },
        },
      },
    },
  },
}
