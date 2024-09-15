---@alias DistanceReturn { distanceX: number, distanceY: number, distance: number, absoluteX: number, absoluteY: number, isHorizontal: boolean, x: number, y: number }

---@param touch table
---@return DistanceReturn | nil
function Swipe.getDistance(touch)
  local currentX, currentY = touch.normalizedPosition.x, touch.normalizedPosition.y
  local previousX, previousY = touch.previousNormalizedPosition.x, touch.previousNormalizedPosition.y
  local distanceX, distanceY = currentX - previousX, currentY - previousY
  local distance = distanceX^2 + distanceY^2
  local absoluteX, absoluteY = math.abs(distanceX), math.abs(distanceY)
  local isHorizontal = absoluteX > absoluteY

  return {
    x = touch.normalizedPosition.x,
    y = touch.normalizedPosition.y,
    distanceX = distanceX,
    distanceY = distanceY,
    distance = distance,
    absoluteX = absoluteX,
    absoluteY = absoluteY,
    isHorizontal = isHorizontal,
  }
end

---@param distance DistanceReturn
function Swipe.toDirection(distance)
  local directions = {
    [Swipe.directions.north] = distance.distanceY > 0 and not distance.isHorizontal,
    [Swipe.directions.east] = distance.distanceX > 0 and distance.isHorizontal,
    [Swipe.directions.south] = distance.distanceY < 0 and not distance.isHorizontal,
    [Swipe.directions.west] = distance.distanceX < 0 and distance.isHorizontal,
  }

  local direction = table.findPair(directions, function (_, isDirection) return isDirection end)

  return direction
end

---@param touch table
function Swipe.getDirection(touch)
  local distance = Swipe.getDistance(touch)
  if not distance then return nil end

  local direction = Swipe.toDirection(distance)

  return direction
end