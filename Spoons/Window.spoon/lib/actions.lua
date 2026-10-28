local keyboardEventTypes = {
  [hs.eventtap.event.types.keyUp] = true,
  [hs.eventtap.event.types.keyDown] = true,
  [hs.eventtap.event.types.flagsChanged] = true,
}

---@param config table
---@param path string
---@return Action | nil
local function findAction(config, path)
  if type(path) ~= 'string' then return nil end

  local current = config

  for key in path:gmatch('[^.]+') do
    if type(current) ~= 'table' then return nil end
    current = current[key]
  end

  if type(current) ~= 'table' or type(current.name) ~= 'string' then return nil end
  if current.config ~= nil and type(current.config) ~= 'table' then return nil end

  return current
end

---@param event Event
---@param action Action
---@return boolean
local function isActionAllowed(event, action)
  local hsEvent = event.hsEvent
  if not hsEvent or not keyboardEventTypes[hsEvent:getType()] then return true end

  local keys = action.keys
  if type(keys) ~= 'table' then return false end

  local flags = hsEvent:getFlags()
  local keyCode = hsEvent:getKeyCode()
  if not flags or not keyCode or not flags:containExactly(keys) then return false end

  local pressedKey = hs.keycodes.map[keyCode]
  for _, key in ipairs(keys) do
    if key == pressedKey then return true end
  end

  return false
end

---@param name string
---@return (fun(event: Event, action: Action): boolean) | nil
local function findActionHandler(name)
  local root, path = name:match('^([^.]+)%.(.+)$')
  if not root then return nil end

  local target = root == 'hs' and hs or (spoon[root] or hs.loadSpoon(root))
  if type(target) ~= 'table' then return nil end

  for key in path:gmatch('[^.]+') do
    target = target[key]
    if target == nil then return nil end
  end

  if type(target) ~= 'function' then return nil end
  return target
end

---@param event Event
---@param config table
---@return boolean
function spoon.Window.handleAction(event, config)
  local action = findAction(config, event.name)
  if not action then return false end

  if action.debug then
    print(string.format('Action %s triggered by %s with config:', action.name, event.name), hs.inspect(action.config))
  end

  if not isActionAllowed(event, action) then return false end

  local handler = findActionHandler(action.name)
  if not handler then return false end

  return not not handler(event, action)
end

---@param event Event?
---@param window hs.window?
---@return hs.window | nil
function spoon.Window.getTargetWindow(event, window)
  return window or (event and event.window) or hs.application.frontmostApplication():focusedWindow()
end
