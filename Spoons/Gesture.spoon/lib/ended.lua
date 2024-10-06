function spoon.Gesture.ended(finalTouch)
  local distances = spoon.Gesture.touches[finalTouch.identity]
  
  if not distances then return end

  local first = distances[1]
  local last = distances[#distances]

  if not first or not last then return end

  local x, y = last.x - first.x, last.y - first.y

  local absoluteX, absoluteY = math.abs(x), math.abs(y)
  local isHorizontal = 16 * absoluteX > 9 * absoluteY

  local direction = spoon.Gesture.toDirection({ distanceX = x, distanceY = y, isHorizontal = isHorizontal })

  spoon.Gesture.touches = {}

  return {
    name = 'ended',
    direction = direction,
  }
end