---@class WindowSwitcher.Style
---@field width number
---@field padding number
---@field rowHeight number
---@field cornerRadius number
---@field textSize number
---@field background table
---@field selection table
---@field textColor table

---@type WindowSwitcher.Style
local style <const> = {
  width = 460,
  padding = 12,
  rowHeight = 40,
  cornerRadius = 10,
  textSize = 16,
  background = { red = 0, green = 0, blue = 0, alpha = 0.92 },
  selection = { red = 1, green = 1, blue = 1, alpha = 0.16 },
  textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
}

spoon.WindowSwitcher.style = style

---@param screen hs.screen
---@param rowCount number
---@return table
local function frameFor(screen, rowCount)
  local screenFrame = screen:frame()
  local height = style.padding * 2 + style.rowHeight * rowCount

  return {
    x = screenFrame.x + (screenFrame.w - style.width) / 2,
    y = screenFrame.y + (screenFrame.h - height) / 2,
    w = style.width,
    h = height,
  }
end

---@param window hs.window
---@return string
local function titleFor(window)
  local title = window:title()
  if not title or title == '' then return '(Untitled)' end

  return title
end

---@param windows hs.window[]
---@param selected number
---@return table[]
local function elementsFor(windows, selected)
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
        y = style.padding / 2 + (selected - 1) * style.rowHeight,
        w = style.width - style.padding,
        h = style.rowHeight,
      },
      fillColor = style.selection,
      roundedRectRadii = { xRadius = 8, yRadius = 8 },
    },
  }

  for index, window in ipairs(windows) do
    local rowY = style.padding + (index - 1) * style.rowHeight

    elements[#elements + 1] = {
      type = 'text',
      action = 'fill',
      text = titleFor(window),
      frame = {
        x = style.padding,
        y = rowY + (style.rowHeight - style.textSize) / 2 - 2,
        w = style.width - style.padding * 2,
        h = style.textSize + 4,
      },
      textColor = style.textColor,
      textSize = style.textSize,
      textFont = '.AppleSystemUIFont',
      textAlignment = 'left',
      textLineBreak = 'truncateTail',
    }
  end

  return elements
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:showUi()
  local screen = self.windows[1] and self.windows[1]:screen() or hs.screen.mainScreen()
  local frame = frameFor(screen, #self.windows)

  if not self.canvas then
    self.canvas = hs.canvas.new(frame)
    self.canvas:level(hs.canvas.windowLevels.floating)
    self.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.fullScreenAuxiliary)
    self.canvas:clickActivating(false)
  else
    self.canvas:frame(frame)
  end

  self.canvas:replaceElements(elementsFor(self.windows, self.selected))
  self.canvas:show()
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:updateUi()
  if not self.canvas then return end

  self.canvas:replaceElements(elementsFor(self.windows, self.selected))
end

---@param self WindowSwitcher
function spoon.WindowSwitcher:hideUi()
  if not self.canvas then return end

  self.canvas:hide()
  self.canvas:delete()
  self.canvas = nil
end
