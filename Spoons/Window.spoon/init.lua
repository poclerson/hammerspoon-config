require('lib')

---@class WindowPlacer
resizer = {
  name = 'Window',
  applicationsScreens = {},
  isHeld = false,
}

require('Spoons/Window.spoon/lib/init')

function resizer:init()
  leftMouseWatcher = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseUp,
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.keyDown,
    },
    function (event)
      resizer:onLeftMouse(event)
    end
  )

  leftMouseWatcher:start()

  -- Check https://www.hammerspoon.org/docs/hs.eventtap.event.html#newKeyEventSequence for event sequences
end

return resizer