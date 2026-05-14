local M = {}

local function should_check()
  local mode = vim.api.nvim_get_mode().mode
  return not (
    mode:match '[cR!s]'
    or vim.fn.getcmdwintype() ~= ''
  )
end

local function should_reload_buffer(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
  local modified = vim.api.nvim_get_option_value('modified', { buf = buf })
  local is_real_file = name ~= '' and not name:match '^%w+://'
  return is_real_file and buftype == '' and not modified
end

local function get_visible_buffers()
  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible[vim.api.nvim_win_get_buf(win)] = true
  end
  return visible
end

local find_buffer_by_filepath = function(filepath)
  local visible_buffers = get_visible_buffers()
  for buf, _ in pairs(visible_buffers) do
    if vim.api.nvim_buf_get_name(buf) == filepath then
      return buf
    end
  end
  return nil
end

require('custom.directory-watcher').registerOnChangeHandler('hotreload', function(filepath, events)
  if not should_check() then
    return
  end

  local buf = find_buffer_by_filepath(filepath)
  if buf and should_reload_buffer(buf) then
    vim.cmd('checktime ' .. buf)
  end
end)

M.setup = function(opts)
  vim.api.nvim_create_autocmd({ 'FocusGained', 'TermLeave', 'BufEnter', 'WinEnter', 'CursorHold', 'CursorHoldI' }, {
    group = vim.api.nvim_create_augroup('hotreload', { clear = true }),
    callback = function()
      if should_check() then
        vim.cmd 'checktime'
      end
    end,
  })
end

return M
