---@param event Event?
---@param action Action
---@param window hs.window?
---@return boolean
function spoon.Window.move(event, action, window)
  local default = spoon.Window.config.default
  local config = action.config
  local target = spoon.Window.getTargetWindow(event, window)
  if not target or not target:isStandard() then return false end

  local direction = (config and config.direction) or (event and event.direction) or default.direction
  if not direction then return false end

  local duration = (config and config.duration) or default.duration or 0
  local moveFnName = 'moveOneScreen' .. direction:sub(1, 1):upper() .. direction:sub(2)
  local moveFn = target[moveFnName]

  if type(moveFn) ~= 'function' then return false end
  moveFn(target, false, true, duration)
  return true
end
