
---comments
---@param touch table
function Swipe.moved(touch)
  local distance = Swipe.getDistance(touch)
  local direction = Swipe.getDirection(touch)

  if not touch.identity then return end

  local id = tostring(touch.identity)

  if not Swipe.touches[id] then
    Swipe.touches[id] = {}
  end

  table.insert(Swipe.touches[id], distance)

  return {
    name = 'moved',
    direction = direction,
  }
end