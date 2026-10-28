---### Gesture
---#### Config
---Maps multi-finger trackpad swipes to actions defined in `config.gestures`.
---
---By default, a four-finger swipe moves the focused window one screen in the
---swiped direction. Disable conflicting macOS trackpad gestures in
---System Settings > Trackpad > More Gestures.
---
---@class Gesture
---@field name string
---@field config Gesture.Config?
---@field watcher hs.eventtap?
---@field swipe Gesture.Swipe
spoon.Gesture = {
  name = 'Gesture',
  config = config.gestures,
  watcher = nil,
  swipe = {
    id = 0,
    triggered = false,
    touches = {},
    size = 0,
    direction = nil,
    distance = 0,
  },
}

require('Spoons/Gesture.spoon/lib/init')

---@param self Gesture
function spoon.Gesture:init()
  if type(self.config) ~= 'table' then return end
  if self.config.enabled == false then return end

  self:start()
end

---@param self Gesture
function spoon.Gesture:start()
  if self.watcher then return end

  self.watcher = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
    return spoon.Gesture.handleEvent(event)
  end)

  self.watcher:start()
end

---@param self Gesture
function spoon.Gesture:stop()
  if not self.watcher then return end

  self.watcher:stop()
  self.watcher = nil
end

return spoon.Gesture
