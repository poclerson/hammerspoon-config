---### WindowSwitcher
---#### Config
---Switches between the windows of the currently focused application using a
---native Cmd+Tab-style UX: hold the configured modifiers, press the cycle key
---to move forward (add Shift to move backward), and release the modifiers to
---focus the selected window. Escape cancels without changing windows.
---
---The shortcut defaults to Alt+Tab and can be changed with `modifiers` (an
---array of `cmd`, `alt`, `ctrl` and/or `shift`) and `key` (a key name or key
---code) in `config.windowSwitcher`.
---
---@class WindowSwitcher
---@field name string
---@field config WindowSwitcher.Config?
---@field watcher hs.eventtap?
---@field canvas hs.canvas?
---@field isOpen boolean
---@field windows hs.window[]
---@field selected number
---@field style WindowSwitcher.Style
spoon.WindowSwitcher = {
  name = 'WindowSwitcher',
  config = config.windowSwitcher,
  watcher = nil,
  canvas = nil,
  isOpen = false,
  windows = {},
  selected = 1,
}

require('Spoons/WindowSwitcher.spoon/lib/init')

---@param self WindowSwitcher
function spoon.WindowSwitcher:init()
  if type(self.config) ~= 'table' then return end
  if self.config.enabled == false then return end

  self:start()
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:start()
  if self.watcher then return end

  self.watcher = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, function(event)
    return spoon.WindowSwitcher:handleEvent(event)
  end)

  self.watcher:start()
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:stop()
  if not self.watcher then return end

  self.watcher:stop()
  self.watcher = nil
  self:close()
end

return spoon.WindowSwitcher
