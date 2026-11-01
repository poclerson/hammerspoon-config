---@param window hs.window
---@return boolean
local function isListable(window)
  return window ~= nil and window:id() ~= nil and window:isStandard()
end

---Returns the focused application's windows, with the focused window first.
---@param self WindowSwitcher
---@return hs.window[]
function spoon.WindowSwitcher:getWindows()
  local app = hs.application.frontmostApplication()
  if not app then return {} end

  local windows = {}
  local focused = app:focusedWindow()

  for _, window in ipairs(app:allWindows()) do
    if isListable(window) then
      windows[#windows + 1] = window
    end
  end

  if focused then
    for index, window in ipairs(windows) do
      if window:id() == focused:id() then
        table.remove(windows, index)
        table.insert(windows, 1, window)
        break
      end
    end
  end

  return windows
end

---@param self WindowSwitcher
---@param backward boolean?
---@return boolean
function spoon.WindowSwitcher:open(backward)
  local windows = self:getWindows()
  if #windows == 0 then return false end

  self.windows = windows
  self.isOpen = true
  self.selected = #windows == 1 and 1 or (backward and #windows or 2)

  self:showUi()
  return true
end

---@param self WindowSwitcher
---@param step number
function spoon.WindowSwitcher:move(step)
  local count = #self.windows
  if not self.isOpen or count == 0 then return end

  self.selected = ((self.selected - 1 + step) % count) + 1
  self:updateUi()
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:commit()
  if not self.isOpen then return end

  local window = self.windows[self.selected]
  self:close()

  if not window then return end

  hs.timer.doAfter(0, function()
    if window:isMinimized() then window:unminimize() end
    window:focus()
    window:raise()
  end)
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:cancel()
  if not self.isOpen then return end

  self:close()
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:close()
  self.isOpen = false
  self.windows = {}
  self.selected = 1

  self:hideUi()
end
