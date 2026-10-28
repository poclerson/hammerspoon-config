---@param event Event
---@param action Action
---@param window hs.window?
---@return boolean
function spoon.Window.place(event, action, window)
  local default = spoon.Window.config.default
  local config = action.config or default
  local target = spoon.Window.getTargetWindow(event, window)
  if not target or not target:isStandard() then return false end

  local frame = target:screen():frame()

  local x = config.x or default.x or 0
  local y = config.y or default.y or 0
  local w = config.w or default.w or 100
  local h = config.h or default.h or 100
  local duration = config.duration or default.duration or 0

  local rect = hs.geometry.rect(
    frame.x + x * frame.w / 100,
    frame.y + y * frame.h / 100,
    w * frame.w / 100,
    h * frame.h / 100
  )

  target:setFrame(rect, duration)
  return true
end
