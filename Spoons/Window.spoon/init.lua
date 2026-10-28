---### Window
---#### Config
---Allows to use any event in `hs.window.filter`
---@class Window
---@field name string
---@field config table
---@field watchers hs.eventtap[]
spoon.Window = {
  name = 'Window',
  config = config.window,
  watchers = {},
}

require('Spoons/Window.spoon/lib/init')

function spoon.Window.init()
  spoon.Window.watchEventtapEvents(config.events)
  spoon.Window.watchWindowEvents(spoon.Window.config)
end

return spoon.Window
