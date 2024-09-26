---### Window
---#### Config
---Allows to use any event in `hs.window.filter`
---@class Window
---@field name string
---@field config table
spoon.Window = {
  name = 'Window',
  config = config.window
}

require('Spoons/Window.spoon/lib/init')

function spoon.Window.init()
  spoon.Window.watchConfigEvents(spoon.Window.config)
end

return spoon.Window