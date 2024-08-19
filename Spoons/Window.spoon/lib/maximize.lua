require('hs/json')

---@param maybeDimension unknown
---@param fallbackDimension number
---@return number
function numberWithFallback(maybeDimension, fallbackDimension)
  return (maybeDimension and type(maybeDimension) == 'number') and maybeDimension or fallbackDimension
end

---Maximizes window while taking stage manager into accountName
---@param window hs.window?
function resizer:maximizeWindow(window)
  if not window or not window:isStandard() then return end

  local config = resizer:getConfig()

  local width = numberWithFallback(config.window.maximizedWidth, 100)
  local height = numberWithFallback(config.window.maximizedHeight, 100)
  local duration = numberWithFallback(config.window.maximizedDuration, 0)

  local max = window:screen():frame()

  window:setFrame({x=max.x, y=max.y, w=max.w * width/height, h=max.h}, duration)
end