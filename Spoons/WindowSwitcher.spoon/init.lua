---### WindowSwitcher
---#### Config
---Switches between the windows of the currently focused application using a
---native Cmd+Tab-style UX: hold the configured modifiers, press the cycle key
---to move forward (add Shift to move backward), and release the modifiers to
---focus the selected window. Up and Down arrows also move the selection,
---Escape cancels without changing windows, and at most 15 items are shown.
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
---@field items table[]
---@field selected number
---@field style table

local Switcher = require('lib/switcher')

---Returns true when a window belongs in the switcher.
---@param window hs.window
---@return boolean
local function isListable(window)
  return window ~= nil and window:id() ~= nil and window:isStandard()
end

---Returns switcher items for the frontmost application's windows.
---@param self Switcher
---@return table[]
local function getWindows(self)
  local app = hs.application.frontmostApplication()
  if not app then return {} end

  local items = {}
  local focused = app:focusedWindow()

  for _, window in ipairs(app:allWindows()) do
    if isListable(window) then
      items[#items + 1] = {
        id = window:id(),
        title = window:title(),
        active = focused ~= nil and window:id() == focused:id(),
        raw = window,
      }
    end
  end

  if focused then
    for index, item in ipairs(items) do
      if item.id == focused:id() then
        table.remove(items, index)
        table.insert(items, 1, item)
        break
      end
    end
  end

  self.windows = {}
  for index, item in ipairs(items) do
    self.windows[index] = item.raw
  end

  return items
end

---Focuses a window from the switcher.
---@param self Switcher
---@param item table
local function focusWindow(self, item)
  local window = item.raw
  if not window then return end

  if window:isMinimized() then window:unminimize() end

  window:focus()
  window:raise()
end

---Returns the screen of the focused window.
---@param self Switcher
---@return hs.screen
local function screenFor(self)
  local window = self.windows and self.windows[1]

  return window and window:screen() or hs.screen.mainScreen()
end

spoon.WindowSwitcher = Switcher.new({
  name = 'WindowSwitcher',
  config = config.windowSwitcher,
  provider = {
    get = getWindows,
    focus = focusWindow,
    screen = screenFor,
  },
  style = {
    width = 460,
    padding = 12,
    rowHeight = 40,
    cornerRadius = 10,
    textSize = 16,
  },
})

spoon.WindowSwitcher.windows = {}

---Returns the focused application's windows, with the focused window first.
---@param self WindowSwitcher
---@return hs.window[]
function spoon.WindowSwitcher:getWindows()
  local items = self.provider.get(self)
  local windows = {}

  for index, item in ipairs(items) do
    windows[index] = item.raw
  end

  return windows
end

local close = spoon.WindowSwitcher.close

---Clears the cached window list and hides the overlay.
---@param self WindowSwitcher
function spoon.WindowSwitcher:close()
  close(self)
  self.windows = {}
end

return spoon.WindowSwitcher
