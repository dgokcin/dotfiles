return {
  "carlos-algms/agentic.nvim",

  --- @type agentic.PartialUserConfig
  opts = {
    -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp" | "kiro-acp" | "pi-acp"
    provider = "claude-agent-acp", -- setting the name here is all you need to get started
  },

  -- these are just suggested keymaps; customize as desired
  keys = {
    {
      "<C-\\>",
      function()
        require("agentic").toggle()
      end,
      mode = { "n", "v", "i" },
      desc = "Toggle Agentic Chat",
    },
    {
      "<C-'>",
      function()
        require("agentic").add_selection_or_file_to_context()
      end,
      mode = { "n", "v" },
      desc = "Add file or selection to Agentic to Context",
    },
    {
      "<C-,>",
      function()
        require("agentic").new_session()
      end,
      mode = { "n", "v", "i" },
      desc = "New Agentic Session",
    },
    {
      "<A-i>r", -- ai Restore
      function()
        require("agentic").restore_session()
      end,
      desc = "Agentic Restore session",
      silent = true,
      mode = { "n", "v", "i" },
    },
    {
      "<leader>ad", -- ai Diagnostics
      function()
        require("agentic").add_current_line_diagnostics()
      end,
      desc = "Add current line diagnostic to Agentic",
      mode = { "n" },
    },
    {
      "<leader>aD", -- ai all Diagnostics
      function()
        require("agentic").add_buffer_diagnostics()
      end,
      desc = "Add all buffer diagnostics to Agentic",
      mode = { "n" },
    },
  },
}
