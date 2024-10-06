---@param touch table
function spoon.Gesture.stationary(touch)
  local direction = spoon.Gesture.getDirection(touch)
  spoon.Gesture.touches = {}

  return {
    name = 'stationary',
    direction = direction,
  }
end