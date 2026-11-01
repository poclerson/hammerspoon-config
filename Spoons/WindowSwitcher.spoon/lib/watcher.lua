local keyDown <const> = hs.eventtap.event.types.keyDown
local flagsChanged <const> = hs.eventtap.event.types.flagsChanged

local escapeKey <const> = hs.keycodes.map.escape
local modifierNames <const> = { 'cmd', 'alt', 'ctrl', 'shift' }

---@param self WindowSwitcher
---@return string[]
local function requiredModifiers(self)
  local configured = self.config and self.config.modifiers

  if type(configured) == 'string' then return { configured } end
  if type(configured) == 'table' and #configured > 0 then return configured end

  return { 'alt' }
end

---@param self WindowSwitcher
---@return number
local function cycleKey(self)
  local key = self.config and self.config.key

  if type(key) == 'number' then return key end
  if type(key) ~= 'string' then key = 'tab' end

  return hs.keycodes.map[key] or hs.keycodes.map[key:lower()] or hs.keycodes.map.tab
end

---@param flags table
---@param required string[]
---@return boolean
local function hasModifiers(flags, required)
  for _, name in ipairs(required) do
    if not flags[name] then return false end
  end

  return true
end

---@param flags table
---@param allowed table<string, boolean>
---@return boolean
local function hasOnlyModifiers(flags, allowed)
  for _, name in ipairs(modifierNames) do
    if flags[name] and not allowed[name] then return false end
  end

  return true
end

---@param event hs.eventtap.event
---@return boolean
function spoon.WindowSwitcher:handleEvent(event)
  local eventType = event:getType()
  local required = requiredModifiers(self)

  if eventType == flagsChanged then
    if self.isOpen and not hasModifiers(event:getFlags(), required) then
      self:commit()
    end
    return false
  end

  local flags = event:getFlags()
  if not hasModifiers(flags, required) then
    if self.isOpen then self:commit() end
    return false
  end

  local allowed = { shift = true }
  for _, name in ipairs(required) do
    allowed[name] = true
  end

  if not hasOnlyModifiers(flags, allowed) then return false end

  local keyCode = event:getKeyCode()
  local isDown = eventType == keyDown

  if keyCode == escapeKey then
    if not self.isOpen then return false end
    if isDown then self:cancel() end
    return true
  end

  if keyCode ~= cycleKey(self) then return false end
  if not isDown then return self.isOpen end

  if not self.isOpen then
    return self:open(flags.shift)
  end

  self:move(flags.shift and -1 or 1)
  return true
end
