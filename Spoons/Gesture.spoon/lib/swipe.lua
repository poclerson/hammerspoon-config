---@class Gesture.Swipe
---@field id number
---@field triggered boolean
---@field touches table<string, Position>
---@field size number
---@field direction string?
---@field distance number
---@field scrollLockUntil number

---@return number
local function now()
  return hs.timer.secondsSinceEpoch()
end

---@param self Gesture.Swipe
function spoon.Gesture.swipe:clear()
  self.touches = {}
  self.size = 0
  self.direction = nil
  self.distance = 0
  self.triggered = false
end

---@param self Gesture.Swipe
---@param timeout number?
function spoon.Gesture.swipe:lockScroll(timeout)
  self.scrollLockUntil = now() + (timeout or 0.6)
end

---@param self Gesture.Swipe
---@return boolean
function spoon.Gesture.swipe:isScrollLocked()
  return now() < self.scrollLockUntil
end

---@param self Gesture.Swipe
---@param touches table[]
---@return boolean
function spoon.Gesture.swipe:none(touches)
  if #touches == 0 then return false end

  for _, touch in ipairs(touches) do
    if self.touches[touch.identity] then return false end
  end

  return true
end

---@param self Gesture.Swipe
---@param touches table[]
---@return boolean
function spoon.Gesture.swipe:all(touches)
  if #touches == 0 then return false end

  for _, touch in ipairs(touches) do
    if not self.touches[touch.identity] then return false end
  end

  return true
end

---@param self Gesture.Swipe
---@param touches table[]
---@return number
function spoon.Gesture.swipe:set(touches)
  self:clear()

  for _, touch in ipairs(touches) do
    self.touches[touch.identity] = {
      x = touch.normalizedPosition.x,
      y = touch.normalizedPosition.y,
    }
    self.size = self.size + 1
  end

  self.id = self.id + 1
  return self.id
end

---@param self Gesture.Swipe
---@param touches table[]
---@return string?, number?
function spoon.Gesture.swipe:detect(touches)
  local left, right, up, down = true, true, true, true
  local deltaX, deltaY = 0, 0
  local size = 0

  for _, touch in ipairs(touches) do
    local start = self.touches[touch.identity]
    if not start then return nil end

    local x = touch.normalizedPosition.x
    local y = touch.normalizedPosition.y
    local x0, y0 = start.x, start.y
    local dx, dy = x - x0, y - y0
    local absoluteX, absoluteY = math.abs(dx), math.abs(dy)
    local moved = touch.phase == 'moved'

    left = left and moved and dx < 0 and absoluteX > absoluteY
    right = right and moved and dx > 0 and absoluteX > absoluteY
    up = up and moved and dy > 0 and absoluteY > absoluteX
    down = down and moved and dy < 0 and absoluteY > absoluteX

    deltaX = deltaX + dx
    deltaY = deltaY + dy

    self.touches[touch.identity] = { x = x, y = y }
    size = size + 1
  end

  if size ~= self.size then return nil end

  local direction
  if left and not (right or up or down) then
    direction = 'left'
  elseif right and not (left or up or down) then
    direction = 'right'
  elseif up and not (left or right or down) then
    direction = 'up'
  elseif down and not (left or right or up) then
    direction = 'down'
  end

  if not direction then return nil end

  deltaX, deltaY = deltaX / size, deltaY / size

  local distance
  if direction == 'left' then
    distance = -deltaX
  elseif direction == 'right' then
    distance = deltaX
  elseif direction == 'up' then
    distance = deltaY
  else
    distance = -deltaY
  end

  if self.direction ~= direction then
    self.direction = direction
    self.distance = 0
  end

  self.distance = self.distance + distance

  return direction, self.distance
end
