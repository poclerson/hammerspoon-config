---Watches config events using `hs.window.filter.default.subscribe`
---@param config table
function spoon.Window.watchConfigEvents(config)
  local possibleTypes = config.types or table.keys(config)
  local types = table.intersections(table.keys(hs.window.filter --[[@as table]]), possibleTypes)
  
  if table.isEmpty(types) then return end
  
  hs.window.filter.default:subscribe(
    types,
    ---@param window hs.window
    ---@param appName string
    ---@param event string
    function(window, appName, event)
      spoon.Utils.handleAction({ name = event }, config[event])
    end
  )
end