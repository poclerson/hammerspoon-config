---@class Window
---@field name string
spoon.Window = {
  name = 'Window',
}

require('Spoons/Window.spoon/lib/init')

function spoon.Window.init()
  hs.window.filter.default:subscribe(
    hs.window.filter.windowFocused,
    ---@param window hs.window
    ---@param appName string
    ---@param event string
    function(window, appName, event)
      local fn = spoon.Window[event]
      if not fn or type(fn) ~= 'function' then return end
      fn(window)
    end
  )

  local possibleEventKeys = table.keys(Config.window)
  local eventKeys = {}

  local possibleEvents = table.each(possibleEventKeys, function (_, possibleKey)
    local key = hs.eventtap.event.types[possibleKey]
    if not key then return end
    table.insert(eventKeys, key)
  end)

  if not possibleEvents then return end

  eventsWatcher = hs.eventtap.new(
    eventKeys,
    function (event)
      local type = event:getType()
      local name = hs.eventtap.event.types[type]
      spoon.Utils.actionDispatcher({ name = name }, Config.window)
    end
  )

  eventsWatcher:start()
end

return spoon.Window