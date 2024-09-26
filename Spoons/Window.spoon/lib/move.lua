---@param customEvent Event?
---@param config EventConfig?
---@param window hs.window?
function spoon.Window.move(customEvent, config, window)
  local default = spoon.Window.config.default
  local safeConfig = config or default
  local windowWithFallback = window or hs.application.frontmostApplication():focusedWindow()
  if not windowWithFallback or not windowWithFallback:isStandard() then return end

  local direction = safeConfig.direction or (customEvent and customEvent.direction) or default.direction

  local duration = safeConfig.duration or default.duration or 0
  if not direction then return end

  local moveFnName = 'moveOneScreen' .. direction:firstToUpper()
  ---@type hs.window:moveOneScreenNorth | nil
  local moveFn = windowWithFallback[moveFnName]

  if not moveFn or type(moveFn) ~= 'function' then return end
  moveFn(windowWithFallback, false, true, duration)
end