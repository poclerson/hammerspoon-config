
---@param touch table
function spoon.Gesture.moved(touch)
  local distance = spoon.Gesture.getDistance(touch)
  local direction = spoon.Gesture.getDirection(touch)

  if not touch.identity then return end

  local id = tostring(touch.identity)

  if not spoon.Gesture.touches[id] then
    spoon.Gesture.touches[id] = {}
  end

  table.insert(spoon.Gesture.touches[id], distance)

  return {
    name = 'moved',
    direction = direction,
  }
end