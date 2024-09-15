require('hs/json')

---@param maybeDimension unknown
---@param fallbackDimension number
---@return number
function safeNumber(maybeDimension, fallbackDimension)
  return (maybeDimension and type(maybeDimension) == 'number') and maybeDimension or fallbackDimension
end

---Applies `config` to `window`. The window will fallback to the frontmost application's window
---@param customEvent Event?
---@param config EventConfig?
---@param window hs.window?
function spoon.Window.place(customEvent, config, window)
  local default = Config.window.default
  local safeConfig = config or default
  local safeWindow = window or hs.application.frontmostApplication():focusedWindow()
  if not safeWindow or not safeWindow:isStandard() then return end

  local frame = safeWindow:screen():frame()

  local x = safeConfig.x or default.x or 0
  local y = safeConfig.y or default.y or 0
  local w = safeConfig.w or default.w or 100
  local h = safeConfig.h or default.h or 100
  local duration = safeConfig.duration or default.duration or 0

  local rect = hs.geometry.rect(
    frame.x + x * frame.w / 100,
    frame.y + y * frame.h / 100,
    w * frame.w / 100,
    h * frame.h / 100
  )

  safeWindow:setFrame(rect, duration)
end