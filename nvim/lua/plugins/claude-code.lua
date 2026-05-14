local claude_float_mode = false

local function toggle_claude_layout()
  vim.cmd("ClaudeCodeClose")
  claude_float_mode = not claude_float_mode
  if claude_float_mode then
    require("claudecode").setup({
      terminal = {
        snacks_win_opts = { position = "float", width = 0.9, height = 0.9, border = "rounded" },
      },
    })
  else
    require("claudecode").setup({
      terminal = { split_side = "right", split_width_percentage = 0.45 },
    })
  end
  vim.cmd("ClaudeCodeOpen")
end

return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.45,
      },
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = true,
        keep_terminal_focus = false,
      },
    },
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      { "<leader>at", toggle_claude_layout, desc = "Toggle Claude float/split" },
    },
  },
}
