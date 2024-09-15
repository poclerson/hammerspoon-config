---@param touch table
function Swipe.stationary(touch)
  local direction = Swipe.getDirection(touch)
  Swipe.touches = {}

  return {
    name = 'stationary',
    direction = direction,
  }
end