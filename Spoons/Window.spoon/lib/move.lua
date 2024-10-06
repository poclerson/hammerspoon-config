---@param event Event?
---@param action Action
---@param window hs.window?
function spoon.Window.move(event, action, window)
  print('window.move')
  inspect(action)
  local default = spoon.Window.config.default
  local safeConfig = action.config or default
  local windowWithFallback = window or hs.application.frontmostApplication():focusedWindow()
  if not windowWithFallback or not windowWithFallback:isStandard() then return end

  local direction = safeConfig.direction or (event and event.direction) or default.direction

  local duration = safeConfig.duration or default.duration or 0
  if not direction then return end

  local moveFnName = 'moveOneScreen' .. direction:firstToUpper()
  ---@type hs.window:moveOneScreenNorth | nil
  local moveFn = windowWithFallback[moveFnName]

  if not moveFn or type(moveFn) ~= 'function' then return false end
  moveFn(windowWithFallback, false, true, duration)
  return true
end