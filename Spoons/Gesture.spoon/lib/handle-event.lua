local gesture <const> = hs.eventtap.event.types.gesture
local scrollWheel <const> = hs.eventtap.event.types.scrollWheel

local directions = {
  up = 'north',
  down = 'south',
  left = 'west',
  right = 'east',
}

---@param actions table
---@param direction string
---@return string?
local function findActionKey(actions, direction)
  local cardinal = directions[direction]

  if type(actions[direction]) == 'table' then return direction end
  if cardinal and type(actions[cardinal]) == 'table' then return cardinal end

  return nil
end

---@param touches table[]
---@return boolean
local function hasPositions(touches)
  for _, touch in ipairs(touches) do
    local position = touch.normalizedPosition

    if not touch.identity or type(position) ~= 'table' then return false end
    if type(position.x) ~= 'number' or type(position.y) ~= 'number' then return false end
  end

  return true
end

---@param direction string
---@return boolean
function spoon.Gesture.trigger(direction)
  local config = spoon.Gesture.config
  local swipe = spoon.Gesture.swipe

  if not config or type(config.actions) ~= 'table' then return false end
  if swipe.triggered then return false end

  local threshold = config.threshold or 0.15
  if swipe.distance < threshold then return false end

  local actionKey = findActionKey(config.actions, direction)
  if not actionKey then return false end

  if not spoon.Window then
    hs.loadSpoon('Window')
  end
  if not spoon.Window or type(spoon.Window.handleAction) ~= 'function' then return false end

  swipe.triggered = true

  return spoon.Window.handleAction({
    name = actionKey,
    direction = directions[direction],
    window = hs.window.focusedWindow(),
  }, config.actions)
end

---@param event hs.eventtap.event
---@return number
local function getEventType(event)
  local eventType = event:getType(true)
  if eventType == nil then return event:getType() end

  return eventType
end

---@param event hs.eventtap.event
---@return boolean
function spoon.Gesture.handleEvent(event)
  local config = spoon.Gesture.config
  if type(config) ~= 'table' then return false end

  local swipe = spoon.Gesture.swipe
  local fingers = config.fingers or 4
  local consume = config.consume ~= false
  local eventType = getEventType(event)

  if eventType == scrollWheel then
    return consume and swipe:isScrollLocked()
  end

  if eventType ~= gesture then return false end

  local touches = event:getTouches()
  if type(touches) ~= 'table' then return false end

  if #touches ~= fingers then return false end
  if not hasPositions(touches) then return false end

  swipe:lockScroll()

  if swipe:none(touches) then
    swipe:set(touches)
  elseif swipe:all(touches) then
    local direction = swipe:detect(touches)
    if direction then spoon.Gesture.trigger(direction) end
  end

  return false
end
