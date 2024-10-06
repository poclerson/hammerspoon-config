---@class Gesture
---@field name string
---@field type string
---@field watcher hs.eventtap | nil
---@field directions {[Direction]: Direction}
---@field fingers [Finger]
---@field touches {[string]: [DistanceReturn]}
---@field phases [string]
spoon.Gesture = {
  name = 'Gesture',
  type = hs.eventtap.event.types.gesture,
  watcher = nil,
  directions = {
    north = 'north',
    east = 'east',
    south = 'south',
    west = 'west',
  },
  fingers = {
    '3',
    '4',
    '5',
  },
  phases = { 'began', 'moved', 'stationary', 'ended', 'cancelled' },
  previous = nil,
  touches = {},
  config = config.__temporary__gesturesSpoon,
}

require('Spoons/Gesture.spoon/lib/init')

spoon.Gesture.cancelled = spoon.Gesture.stationary
spoon.Gesture.began = spoon.Gesture.moved

function spoon.Gesture:init()
  self.watcher = hs.eventtap.new(
    { self.type }, 
    ---@param event hs.eventtap.event
    function(event)
      local touches = event:getTouches() --[[@as table]]
      local fingers = #touches

      if fingers <= 2 then return end

      table.each(touches, function(index, touch)
        
        if
          not table.some(spoon.Gesture.phases, function (_, value) return touch.phase == value end) or
          not touch or
          not touch.identity
        then
          return end

        if not spoon.Gesture[touch.phase] or type(spoon.Gesture[touch.phase]) ~= 'function' or not touch or type(touch) ~= 'table' then return end

        local result = spoon.Gesture[touch.phase](touch, index) or {}
        local direction = result.direction

        if touch.phase ~= 'ended' or not direction then return end

        spoon.Utils.handleAction({ direction = direction, name = touch.phase }, spoon.Gesture.config, direction, fingers)
      end)
    end
  )

  self.watcher:start()
end

return spoon.Gesture