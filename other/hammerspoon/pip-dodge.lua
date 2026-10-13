-- Moves Dia's Picture-in-Picture window out from under the mouse.
--
-- Intent rules
--   Cursor sits in the PiP interior for a short dwell -> glide to a corner that clears it.
--   Cursor in the edge or corner band -> resize grab, hold still.
--   Mouse button held (dragging or resizing) -> hold still.
--   Hold modifier pressed (default alt) -> hold still.
--   Cursor follows the PiP to its new spot -> you want it, so it stays pinned
--   until the cursor leaves, plus a short grace period for re-entries.

local M = {}

M.config = {
  bundleID = "company.thebrowser.dia",
  subrolePattern = "SystemDialog|Floating",  -- Dia's PiP reports AXSystemDialog
  minSize = 150,                 -- ignores autofill dropdowns and helper windows
  edgeBand = 28,                 -- px inside the frame that counts as a resize handle
  dwell = 0.10,                  -- seconds the cursor must sit in the interior
  cooldown = 0.40,               -- seconds after a jump before the next one
  chaseWindow = 2.5,             -- re-entry this soon after a jump pins the PiP
  pinGrace = 1.0,                -- re-entry this soon after unpinning pins it again
  margin = 20,                   -- gap from screen edges when parking
  animation = 0.15,              -- seconds the window takes to glide to its corner
  pollInterval = 0.05,
  windowCacheTTL = 1.0,
  holdModifier = "alt",
}

local state = {
  enabled = true,
  timer = nil,
  interiorSince = nil,
  wasInside = false,
  pinned = false,
  unpinnedAt = 0,
  lastDodgeAt = 0,
  cachedWindow = nil,
  cachedAt = 0,
}

local function now() return hs.timer.secondsSinceEpoch() end

local function log(fmt, ...)
  if M.verbose then print(("[pip-dodge] " .. fmt):format(...)) end
end

-- Window lookup -------------------------------------------------------------

local function looksLikePip(w)
  if not w:isVisible() or w:isMinimized() or w:isStandard() then return false end

  local f = w:frame()
  if f.w < M.config.minSize or f.h < M.config.minSize then return false end
  local sf = (w:screen() or hs.screen.mainScreen()):frame()
  if f.w * f.h > 0.5 * sf.w * sf.h then return false end

  local subrole = w:subrole() or ""
  for pat in M.config.subrolePattern:gmatch("[^|]+") do
    if subrole:match(pat) then return true end
  end
  return false
end

local function pipWindow()
  local t = now()
  local cached = state.cachedWindow
  if cached and t - state.cachedAt < M.config.windowCacheTTL then
    if cached:isVisible() then return cached end
    state.cachedWindow = nil
  end

  state.cachedAt = t
  state.cachedWindow = nil
  for _, app in ipairs(hs.application.applicationsForBundleID(M.config.bundleID)) do
    for _, w in ipairs(app:allWindows()) do
      if looksLikePip(w) then
        state.cachedWindow = w
        return w
      end
    end
  end
  return nil
end

-- Geometry ------------------------------------------------------------------

local function pointIn(p, f)
  return p.x >= f.x and p.x < f.x + f.w and p.y >= f.y and p.y < f.y + f.h
end

local function inInterior(p, f)
  local b = M.config.edgeBand
  return pointIn(p, { x = f.x + b, y = f.y + b, w = f.w - 2 * b, h = f.h - 2 * b })
end

-- Corners of the PiP's screen, opposite corner first, then the two adjacent ones.
-- Returns the first frame that leaves the cursor outside it, or nil if none does.
local function escapeFrame(w, mouse)
  local f = w:frame()
  local s = w:screen():frame()
  local m = M.config.margin
  local left, right = s.x + m, s.x + s.w - f.w - m
  local top, bottom = s.y + m, s.y + s.h - f.h - m
  local onLeft = f.x + f.w / 2 < s.x + s.w / 2
  local onTop = f.y + f.h / 2 < s.y + s.h / 2

  local candidates = {
    { x = onLeft and right or left, y = onTop and bottom or top },
    { x = onLeft and right or left, y = onTop and top or bottom },
    { x = onLeft and left or right, y = onTop and bottom or top },
  }
  for _, c in ipairs(candidates) do
    local target = hs.geometry.rect(c.x, c.y, f.w, f.h)
    if not pointIn(mouse, target) then return target end
  end
  return nil
end

-- Decision ------------------------------------------------------------------

local function holdRequested()
  if hs.eventtap.checkKeyboardModifiers()[M.config.holdModifier] then return true end
  local buttons = hs.eventtap.checkMouseButtons()
  return buttons.left or buttons.right
end

local function tick()
  if not state.enabled then return end
  local t = now()

  local w = pipWindow()
  if not w then
    state.interiorSince, state.wasInside, state.pinned = nil, false, false
    return
  end

  local mouse = hs.mouse.absolutePosition()
  local frame = w:frame()
  local inside = pointIn(mouse, frame)
  local entering = inside and not state.wasInside
  state.wasInside = inside

  if state.pinned then
    if inside then return end
    state.pinned = false
    state.unpinnedAt = t
    log("unpinned")
    return
  end

  if not inside then state.interiorSince = nil; return end

  -- Coming back right after a jump, or shortly after unpinning, means you want it.
  if entering and (t - state.lastDodgeAt < M.config.chaseWindow
                   or t - state.unpinnedAt < M.config.pinGrace) then
    state.pinned = true
    state.interiorSince = nil
    log("pinned: cursor followed the window")
    return
  end

  if t - state.lastDodgeAt < M.config.cooldown then return end
  if not inInterior(mouse, frame) or holdRequested() then
    state.interiorSince = nil
    return
  end

  state.interiorSince = state.interiorSince or t
  if t - state.interiorSince < M.config.dwell then return end

  local target = escapeFrame(w, mouse)
  state.interiorSince = nil
  if not target then
    state.pinned = true
    log("pinned: no corner clears the cursor")
    return
  end

  w:setFrame(target, M.config.animation)
  state.lastDodgeAt = t
  state.wasInside = false
  log("dodged to %d,%d", target.x, target.y)
end

-- Public API ----------------------------------------------------------------

function M.start()
  if state.timer then return M end
  state.timer = hs.timer.doEvery(M.config.pollInterval, tick)
  return M
end

function M.stop()
  if state.timer then state.timer:stop(); state.timer = nil end
  state.interiorSince, state.pinned = nil, false
end

function M.toggle()
  state.enabled = not state.enabled
  state.interiorSince, state.pinned = nil, false
  hs.alert.show(state.enabled and "PiP dodge on" or "PiP dodge off", 0.8)
end

-- Prints every Dia window so subrolePattern and minSize can be tuned.
function M.dumpWindows()
  for _, app in ipairs(hs.application.applicationsForBundleID(M.config.bundleID)) do
    for _, w in ipairs(app:allWindows()) do
      local f = w:frame()
      print(("[pip-dodge] title=%q subrole=%s standard=%s frame=%dx%d@%d,%d pip=%s"):format(
        w:title() or "", tostring(w:subrole()), tostring(w:isStandard()),
        f.w, f.h, f.x, f.y, tostring(looksLikePip(w))))
    end
  end
  hs.alert.show("Dia windows dumped to console", 0.8)
end

return M
