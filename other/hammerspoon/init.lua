require("hs.ipc")
hs.window.animationDuration = 0

local pipDodge = require("pip-dodge")
pipDodge.start()

local hyper = { "cmd", "alt", "ctrl" }
hs.hotkey.bind(hyper, "p", pipDodge.toggle)
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "p", pipDodge.dumpWindows)
hs.hotkey.bind(hyper, "r", hs.reload)

hs.alert.show("Hammerspoon loaded", 0.6)
