-- return {
--   "coder/claudecode.nvim",
--   dependencies = { "folke/snacks.nvim" },
--   config = true,
--   keys = {
--     { "<leader>a", nil, desc = "AI/Claude Code" },
--     { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
--     { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
--     { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
--     { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
--     { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
--     { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
--     { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
--     {
--       "<leader>as",
--       "<cmd>ClaudeCodeTreeAdd<cr>",
--       desc = "Add file",
--       ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
--     },
--     -- Diff management
--     { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
--     { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
--   },
-- }

-- return {
--   "greggh/claude-code.nvim",
--   dependencies = {
--     "nvim-lua/plenary.nvim", -- Required for git operations
--   },
--   config = function()
--     require("claude-code").setup()
--   end,
-- }

return {
  "Cannon07/code-preview.nvim",
  config = function()
    require("code-preview").setup({
      diff = {
        layout = "vsplit", -- "tab" (new tab) | "vsplit" (current tab) | "inline" (GitHub-style)
        labels = { current = "CURRENT", proposed = "PROPOSED" },
        equalize = true, -- 50/50 split widths (tab/vsplit only)
        full_file = true, -- show full file, not just diff hunks (tab/vsplit only)
        visible_only = false, -- skip diffs for files not open in any Neovim buffer
        defer_claude_permissions = false, -- for Claude Code: let its own settings decide, don't prompt
      },
      highlights = {
        current = { -- CURRENT (original) side — tab/vsplit layouts
          DiffAdd = { bg = "#4c2e2e" },
          DiffDelete = { bg = "#4c2e2e" },
          DiffChange = { bg = "#4c3a2e" },
          DiffText = { bg = "#5c3030" },
        },
        proposed = { -- PROPOSED side — tab/vsplit layouts
          DiffAdd = { bg = "#2e4c2e" },
          DiffDelete = { bg = "#4c2e2e" },
          DiffChange = { bg = "#2e3c4c" },
          DiffText = { bg = "#3e5c3e" },
        },
        inline = { -- inline layout
          added = { bg = "#2e4c2e" }, -- added line background
          removed = { bg = "#4c2e2e" }, -- removed line background
          added_text = { bg = "#3a6e3a" }, -- changed characters (added)
          removed_text = { bg = "#6e3a3a" }, -- changed characters (removed)
        },
      },
    })
  end,
}
