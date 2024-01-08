return {
  'zbirenbaum/copilot-cmp',
  dependencies = {
    'zbirenbaum/copilot.lua',
  },
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
    })

    require('copilot_cmp').setup()
  end,
}