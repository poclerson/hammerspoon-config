---### TabSwitcher
---#### Config
---Switches between the tabs of the frontmost window of the frontmost application.
---Hold the configured modifiers, press the cycle key to move forward (add Shift
---to move backward), and release the modifiers to focus the selected tab.
---Up and Down arrows also move the selection, Escape cancels without changing
---tabs, and at most 15 items are shown.
---
---Supported applications are Arc, Terminal, VS Code and Obsidian. VS Code and
---Obsidian need their local bridges installed; both bridges live next to this
---spoon in `bridges/`. Arc tabs show their space in brackets as a context label.
---
---The shortcut defaults to Ctrl+Tab and can be changed with `modifiers` (an
---array of `cmd`, `alt`, `ctrl` and/or `shift`) and `key` (a key name or key
---code) in `config.tabSwitcher`.
---
---The number of tabs fetched and shown per app can be limited with `limits` in
---`config.tabSwitcher`, keyed by `arc`, `terminal`, `vscode` or `obsidian`.
---The default is 15, and Arc defaults to 5 to keep its AppleScript fast.
---
---@class TabSwitcher
---@field name string
---@field config TabSwitcher.Config?
---@field watcher hs.eventtap?
---@field canvas hs.canvas?
---@field isOpen boolean
---@field items table[]
---@field selected number
---@field style table

local Switcher = require('lib/switcher')
local adapters = require('Spoons/TabSwitcher.spoon/lib/adapters')

local history = {}
local clock = 0

---Returns the next recency timestamp.
---@return number
local function nextTick()
  clock = clock + 1
  return clock
end

---Returns the history key for the focused window of an application.
---@param app hs.application
---@return string
local function historyKey(app)
  local window = app:focusedWindow()
  local windowId = window and window:id() or 'none'

  return string.format('%s:%s', tostring(app:bundleID()), tostring(windowId))
end

---Updates the recency history for a tab.
---@param app hs.application
---@param id string
local function remember(app, id)
  local key = historyKey(app)
  local bucket = history[key] or {}

  bucket[id] = nextTick()
  history[key] = bucket
end

---Rotates the active tab to the front of the list.
---@param items table[]
---@return table[]
local function rotateActive(items)
  local activeIndex = nil

  for index, item in ipairs(items) do
    if item.active then
      activeIndex = index
      break
    end
  end

  if not activeIndex then return items end

  local rotated = {}

  for index = activeIndex, #items do
    rotated[#rotated + 1] = items[index]
  end

  for index = 1, activeIndex - 1 do
    rotated[#rotated + 1] = items[index]
  end

  return rotated
end

---Sorts tabs by per-window recency, keeping tab-strip order for new tabs.
---@param app hs.application
---@param items table[]
---@return table[]
local function orderTabs(app, items)
  local rotated = rotateActive(items)
  local key = historyKey(app)
  local bucket = history[key] or {}

  for _, item in ipairs(rotated) do
    if item.active then bucket[item.id] = nextTick() end
  end

  for index, item in ipairs(rotated) do
    item._order = index
    item._rank = bucket[item.id] or 0
  end

  table.sort(rotated, function(left, right)
    if left._rank ~= right._rank then return left._rank > right._rank end
    return left._order < right._order
  end)

  local keep = {}
  for _, item in ipairs(rotated) do keep[item.id] = true end
  for id in pairs(bucket) do
    if not keep[id] then bucket[id] = nil end
  end

  history[key] = bucket

  return rotated
end

---Returns the per-app fetch limit, capped to the shared 15-item maximum.
---@param self TabSwitcher
---@param adapter table
---@return number
local function tabLimit(self, adapter)
  local limits = self.config and self.config.limits
  local configured = nil

  if type(limits) == 'table' then
    configured = limits[adapter.key]
      or (adapter.name and limits[adapter.name:lower()])
      or limits[self.bundleID]
  end

  local limit = math.floor(tonumber(configured) or tonumber(adapter.limit) or 15)
  if limit < 1 then limit = 1 end

  return math.min(limit, 15)
end

---Returns the tabs of the frontmost window of the frontmost application.
---@param self TabSwitcher
---@return table[]
local function getTabs(self)
  local app = hs.application.frontmostApplication()
  if not app then return {} end

  self.app = app
  self.bundleID = app:bundleID()
  self.adapter = nil

  local adapter = adapters[self.bundleID]
  if not adapter then return {} end

  self.adapter = adapter
  local limit = tabLimit(self, adapter)

  local ok, items, err = pcall(adapter.list, app, limit)
  if not ok then
    self:notify('TabSwitcher: ' .. tostring(items))
    return {}
  end

  if not items then
    self:notify('TabSwitcher: ' .. tostring(err))
    return {}
  end

  if #items == 0 then return {} end

  local ordered = orderTabs(app, items)
  if #ordered > limit then
    for index = #ordered, limit + 1, -1 do ordered[index] = nil end
  end

  return ordered
end

---Focuses a tab through the current application's adapter.
---@param self TabSwitcher
---@param item table
local function focusTab(self, item)
  local app = self.app
  local adapter = self.adapter
  if not app or not adapter then return end

  if app:isRunning() then app:activate() end

  local ok, success, err = pcall(adapter.focus, app, item.id)
  if not ok then
    self:notify('TabSwitcher: ' .. tostring(success))
    return
  end

  if success == false then
    self:notify('TabSwitcher: ' .. tostring(err))
    return
  end

  remember(app, item.id)
end

---Returns the screen of the focused window.
---@param self TabSwitcher
---@return hs.screen
local function screenFor(self)
  local window = self.app and self.app:focusedWindow()

  return window and window:screen() or hs.screen.mainScreen()
end

spoon.TabSwitcher = Switcher.new({
  name = 'TabSwitcher',
  config = config.tabSwitcher,
  provider = {
    get = getTabs,
    focus = focusTab,
    screen = screenFor,
  },
  style = {
    width = 620,
    padding = 12,
    rowHeight = 36,
    cornerRadius = 10,
    textSize = 14,
    maxRows = 10,
  },
})

spoon.TabSwitcher.adapters = adapters

---Returns the current app's tabs, ordered by recency.
---@param self TabSwitcher
---@return table[]
function spoon.TabSwitcher:getTabs()
  return self.provider.get(self)
end

return spoon.TabSwitcher
