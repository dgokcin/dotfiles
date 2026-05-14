local M = {}

local uv = vim.uv
local watcher = nil
local debounce_timer = nil
local on_change_handlers = {}

local debounce = function(fn, delay)
  return function(...)
    local args = { ... }
    if debounce_timer then
      debounce_timer:close()
    end
    debounce_timer = vim.defer_fn(function()
      debounce_timer = nil
      fn(unpack(args))
    end, delay)
  end
end

M.registerOnChangeHandler = function(name, handler)
  on_change_handlers[name] = handler
end

M.setup = function(opts)
  opts = opts or {}
  local path = opts.path
  local debounce_delay = opts.debounce or 100

  if not path then
    return false
  end

  if watcher then
    M.stop()
  end

  local fs_event = uv.new_fs_event()
  if not fs_event then
    return false
  end

  local on_change = debounce(function(err, filename, events)
    if err then
      M.stop()
      return
    end

    if filename then
      local full_path = path .. '/' .. filename
      for _, handler in pairs(on_change_handlers) do
        pcall(handler, full_path, events)
      end
    end
  end, debounce_delay)

  local ok, err = fs_event:start(path, { recursive = true }, vim.schedule_wrap(on_change))

  if ok ~= 0 then
    return false
  end

  watcher = fs_event
  return true
end

M.stop = function()
  if watcher then
    watcher:stop()
    watcher = nil
  end

  if debounce_timer then
    debounce_timer:close()
    debounce_timer = nil
  end
end

return M
