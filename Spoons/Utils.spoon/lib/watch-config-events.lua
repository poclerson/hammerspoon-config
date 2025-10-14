---Watches config events using `hs.eventtap.new`
---@param config table
function spoon.Utils.watchConfigEvents(config)
  if not config then return end
  local possibleTypes = config.types or table.keys(config)

  local types = table.flatMap(possibleTypes, function (_, value)
    local type = hs.eventtap.event.types[value]
    if not type then return {} end
    return { type }
  end)
  
  if not types or table.isEmpty(types) then return end

  watcher = hs.eventtap.new(types, function (event)
    local type = event:getType(true)
    local name = hs.eventtap.event.types[type]
  
    spoon.Utils.handleAction({ name = name, hsEvent = event }, config)
  end)

  watcher:start()
end