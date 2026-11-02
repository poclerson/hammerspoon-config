---@class Switcher
---@field name string
---@field config table?
---@field style table
---@field items table[]
---@field selected number
---@field isOpen boolean
---@field watcher hs.eventtap?
---@field canvas hs.canvas?
local Switcher = {}
Switcher.__index = Switcher

local keyDown <const> = hs.eventtap.event.types.keyDown
local keyUp <const> = hs.eventtap.event.types.keyUp
local flagsChanged <const> = hs.eventtap.event.types.flagsChanged
local escapeKey <const> = hs.keycodes.map.escape
local upKey <const> = hs.keycodes.map.up
local downKey <const> = hs.keycodes.map.down
local modifierNames <const> = { 'cmd', 'alt', 'ctrl', 'shift' }
local maxItems <const> = 15

local defaultStyle <const> = {
  width = 460,
  padding = 12,
  rowHeight = 40,
  cornerRadius = 10,
  textSize = 16,
  maxRows = nil,
  background = { red = 0, green = 0, blue = 0, alpha = 0.92 },
  selection = { red = 1, green = 1, blue = 1, alpha = 0.16 },
  textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
  contextColor = { red = 0.86, green = 0.87, blue = 0.89, alpha = 0.72 },
  counterColor = { red = 1, green = 1, blue = 1, alpha = 0.55 },
  contextWidth = nil,
  contextGap = 8,
  contextMaxWidth = 180,
}

---Merges a style over the defaults.
local function makeStyle(overrides)
  local style = {}

  for key, value in pairs(defaultStyle) do
    style[key] = value
  end

  if overrides then
    for key, value in pairs(overrides) do
      style[key] = value
    end
  end

  return style
end

---Creates a switcher backed by a provider.
---@param options table
---@return Switcher
function Switcher.new(options)
  local self = setmetatable({}, Switcher)

  self.name = options.name
  self.config = options.config
  self.provider = options.provider
  self.style = makeStyle(options.style)
  self.items = {}
  self.selected = 1
  self.isOpen = false
  self.watcher = nil
  self.canvas = nil

  return self
end

---Shows a short alert for the current switcher.
---@param self Switcher
---@param message string
function Switcher:notify(message)
  hs.alert.show(tostring(message))
end

---Starts the switcher if it is enabled in the config.
---@param self Switcher
function Switcher:init()
  if type(self.config) ~= 'table' then return end
  if self.config.enabled == false then return end

  self:start()
end

---Starts the event watcher.
---@param self Switcher
function Switcher:start()
  if self.watcher then return end

  self.watcher = hs.eventtap.new({
    keyDown,
    keyUp,
    flagsChanged,
  }, function(event)
    return self:handleEvent(event)
  end)

  self.watcher:start()
end

---Stops the event watcher and closes the overlay.
---@param self Switcher
function Switcher:stop()
  if self.watcher then
    self.watcher:stop()
    self.watcher = nil
  end

  self:close()
end

---Returns the configured modifiers, defaulting to Alt.
---@param self Switcher
---@return string[]
local function requiredModifiers(self)
  local configured = self.config and self.config.modifiers

  if type(configured) == 'string' then return { configured } end
  if type(configured) == 'table' and #configured > 0 then return configured end

  return { 'alt' }
end

---Returns the configured cycle key code, defaulting to Tab.
---@param self Switcher
---@return number
local function cycleKey(self)
  local key = self.config and self.config.key

  if type(key) == 'number' then return key end
  if type(key) ~= 'string' then key = 'tab' end

  return hs.keycodes.map[key] or hs.keycodes.map[key:lower()] or hs.keycodes.map.tab
end

---Returns true when every required modifier is held.
---@param flags table
---@param required string[]
---@return boolean
local function hasModifiers(flags, required)
  for _, name in ipairs(required) do
    if not flags[name] then return false end
  end

  return true
end

---Returns true when no unlisted modifier is held.
---@param flags table
---@param allowed table<string, boolean>
---@return boolean
local function hasOnlyModifiers(flags, allowed)
  for _, name in ipairs(modifierNames) do
    if flags[name] and not allowed[name] then return false end
  end

  return true
end

---Handles key and modifier events for the switcher.
---@param self Switcher
---@param event hs.eventtap.event
---@return boolean
function Switcher:handleEvent(event)
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

  if keyCode == upKey or keyCode == downKey then
    if not self.isOpen then return false end
    if isDown then self:move(keyCode == upKey and -1 or 1) end
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

---Returns the items to display, using the provider hook.
---@param self Switcher
---@return table[]
function Switcher:getItems()
  return self.provider.get(self)
end

---Returns the screen that should host the overlay.
---@param self Switcher
---@return hs.screen
function Switcher:screen()
  if self.provider.screen then return self.provider.screen(self) end

  return hs.screen.mainScreen()
end

---Opens the overlay with the provider's current items.
---@param self Switcher
---@param backward boolean?
---@return boolean
function Switcher:open(backward)
  local ok, items = pcall(self.getItems, self)

  if not ok then
    self:notify(self.name .. ': ' .. tostring(items))
    return false
  end

  if type(items) ~= 'table' then return false end

  local count = math.min(#items, maxItems)
  for index = #items, count + 1, -1 do items[index] = nil end
  if count == 0 then return false end

  self.items = items
  self.isOpen = true
  self.selected = count == 1 and 1 or (backward and count or 2)

  self:showUi()
  return true
end

---Moves the selection by the given step, wrapping around.
---@param self Switcher
---@param step number
function Switcher:move(step)
  local count = #self.items
  if not self.isOpen or count == 0 then return end

  self.selected = ((self.selected - 1 + step) % count) + 1
  self:updateUi()
end

---Focuses the selected item and closes the overlay.
---@param self Switcher
function Switcher:commit()
  if not self.isOpen then return end

  local item = self.items[self.selected]
  self:close()

  if not item then return end

  hs.timer.doAfter(0, function()
    local ok, err = pcall(self.provider.focus, self, item)
    if not ok then self:notify(self.name .. ': ' .. tostring(err)) end
  end)
end

---Closes the overlay without focusing anything.
---@param self Switcher
function Switcher:cancel()
  if not self.isOpen then return end

  self:close()
end

---Resets the switcher state and hides the overlay.
---@param self Switcher
function Switcher:close()
  self.isOpen = false
  self.items = {}
  self.selected = 1

  self:hideUi()
end

---Returns the visible row range and row count.
---@param style table
---@param total number
---@param selected number
---@return number, number, number
local function visibleRange(style, total, selected)
  local visible = math.min(total, style.maxRows or total)
  if visible < 1 then visible = 1 end

  local first = selected - math.floor(visible / 2)
  local last = first + visible - 1

  if first < 1 then
    first = 1
    last = first + visible - 1
  end

  if last > total then
    last = total
    first = last - visible + 1
  end

  if first < 1 then first = 1 end

  return first, last, visible
end

---Returns the overlay frame for a screen.
---@param screen hs.screen
---@param style table
---@param visible number
---@param showCounter boolean
---@return table
local function frameFor(screen, style, visible, showCounter)
  local screenFrame = screen:frame()
  local footer = showCounter and (style.textSize + 8) or 0
  local height = style.padding * 2 + style.rowHeight * visible + footer

  return {
    x = screenFrame.x + (screenFrame.w - style.width) / 2,
    y = screenFrame.y + (screenFrame.h - height) / 2,
    w = style.width,
    h = height,
  }
end

---Returns a display title for an item.
---@param item table
---@return string
local function titleFor(item)
  local title = item.title or item.name
  if not title or title == '' then return '(Untitled)' end

  return tostring(title)
end

---Returns the optional context label for an item.
---@param item table
---@return string?
local function contextFor(item)
  local context = item.context
  if context == nil or context == '' then return nil end

  return tostring(context)
end

---Returns the shared width of the context column for a row range.
---@param style table
---@param items table[]
---@param first number
---@param last number
---@return number?
local function contextWidthFor(style, items, first, last)
  if type(style.contextWidth) == 'number' then return style.contextWidth end

  local width = nil

  for index = first, last do
    local item = items[index]
    local context = contextFor(item)

    if context then
      width = math.max(width or 0, #context * 7 + style.contextGap)
    end

    if type(item.contextWidth) == 'number' then
      width = math.max(width or 0, item.contextWidth)
    end
  end

  if not width then return nil end

  return math.min(width, style.contextMaxWidth)
end

---Builds the canvas elements for the current state.
---@param self Switcher
---@return table[]
local function elementsFor(self)
  local style = self.style
  local total = #self.items
  local first, last, visible = visibleRange(style, total, self.selected)
  local showCounter = total > visible
  local selectedRow = self.selected - first
  local contextWidth = contextWidthFor(style, self.items, 1, total)

  local elements = {
    {
      type = 'rectangle',
      action = 'fill',
      frame = { x = 0, y = 0, w = '100%', h = '100%' },
      fillColor = style.background,
      roundedRectRadii = { xRadius = style.cornerRadius, yRadius = style.cornerRadius },
    },
    {
      type = 'rectangle',
      action = 'fill',
      frame = {
        x = style.padding / 2,
        y = style.padding / 2 + selectedRow * style.rowHeight,
        w = style.width - style.padding,
        h = style.rowHeight,
      },
      fillColor = style.selection,
      roundedRectRadii = { xRadius = 8, yRadius = 8 },
    },
  }

  for index = first, last do
    local item = self.items[index]
    local rowY = style.padding + (index - first) * style.rowHeight
    local textY = rowY + (style.rowHeight - style.textSize) / 2 - 2
    local titleX = style.padding
    local context = contextFor(item)

    if contextWidth then
      titleX = titleX + contextWidth

      if context then
        elements[#elements + 1] = {
          type = 'text',
          action = 'fill',
          text = context,
          frame = {
            x = style.padding,
            y = textY,
            w = math.max(1, contextWidth - style.contextGap),
            h = style.textSize + 4,
          },
          textColor = item.contextColor or style.contextColor,
          textSize = style.textSize,
          textFont = '.AppleSystemUIFont',
          textAlignment = 'left',
          textLineBreak = 'truncateTail',
        }
      end
    end

    elements[#elements + 1] = {
      type = 'text',
      action = 'fill',
      text = titleFor(item),
      frame = {
        x = titleX,
        y = textY,
        w = style.width - titleX - style.padding,
        h = style.textSize + 4,
      },
      textColor = style.textColor,
      textSize = style.textSize,
      textFont = '.AppleSystemUIFont',
      textAlignment = 'left',
      textLineBreak = 'truncateTail',
    }
  end

  if showCounter then
    elements[#elements + 1] = {
      type = 'text',
      action = 'fill',
      text = string.format('%d / %d', self.selected, total),
      frame = {
        x = style.padding,
        y = style.padding + style.rowHeight * visible + 4,
        w = style.width - style.padding * 2,
        h = style.textSize + 4,
      },
      textColor = style.counterColor,
      textSize = style.textSize,
      textFont = '.AppleSystemUIFont',
      textAlignment = 'right',
    }
  end

  return elements
end

---Shows the overlay on the configured screen.
---@param self Switcher
function Switcher:showUi()
  local style = self.style
  local total = #self.items
  local _, _, visible = visibleRange(style, total, self.selected)
  local showCounter = total > visible
  local frame = frameFor(self:screen(), style, visible, showCounter)

  if not self.canvas then
    self.canvas = hs.canvas.new(frame)
    self.canvas:level(hs.canvas.windowLevels.floating)
    self.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.fullScreenAuxiliary)
    self.canvas:clickActivating(false)
  else
    self.canvas:frame(frame)
  end

  self.canvas:replaceElements(elementsFor(self))
  self.canvas:show()
end

---Redraws the overlay after the selection changes.
---@param self Switcher
function Switcher:updateUi()
  if not self.canvas then return end

  self.canvas:replaceElements(elementsFor(self))
end

---Hides and destroys the overlay.
---@param self Switcher
function Switcher:hideUi()
  if not self.canvas then return end

  self.canvas:hide()
  self.canvas:delete()
  self.canvas = nil
end

return Switcher
