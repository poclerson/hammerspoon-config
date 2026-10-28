---@param config table
---@return string[]
local function getEventNames(config)
  if config.types then return config.types end

  local names = {}
  for name in pairs(config) do
    names[#names + 1] = name
  end
  return names
end

---@param config table
---@param eventTypes table
---@return (number | string)[]
local function getEventTypes(config, eventTypes)
  local types = {}

  for _, name in ipairs(getEventNames(config)) do
    local eventType = eventTypes[name]
    if type(eventType) == 'number' or type(eventType) == 'string' then
      types[#types + 1] = eventType
    end
  end

  return types
end

---@param config table
function spoon.Window.watchEventtapEvents(config)
  if not config then return end

  local types = getEventTypes(config, hs.eventtap.event.types)
  if #types == 0 then return end

  local watcher = hs.eventtap.new(types, function(event)
    local name = hs.eventtap.event.types[event:getType(true)]
    if not name then return end
    spoon.Window.handleAction({ name = name, hsEvent = event }, config)
  end)

  spoon.Window.watchers[#spoon.Window.watchers + 1] = watcher
  watcher:start()
end

---@param config table
function spoon.Window.watchWindowEvents(config)
  if not config then return end

  local types = getEventTypes(config, hs.window.filter)
  if #types == 0 then return end

  hs.window.filter.default:subscribe(types, function(window, _, event)
    spoon.Window.handleAction({ name = event, window = window }, config)
  end)
end
