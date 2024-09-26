---Watches config events using `hs.eventtap.new`
---@param config table
function spoon.Utils.watchConfigEvents(config)
  local possibleTypes = config.types or table.keys(config)
  local types = table.keys(table.intersections(hs.eventtap.event.types, possibleTypes))

  if not types or table.isEmpty(types) then return end

  watcher = hs.eventtap.new(types, function (event)
    local type = event:getType(true)
    local name = hs.eventtap.event.types[type]
  
    spoon.Utils.handleAction({ name = name }, config)
  end)

  watcher:start()
end