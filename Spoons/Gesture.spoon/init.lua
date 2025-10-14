---@class Gesture
---@field name string
---@field touches {[string]: [DistanceReturn]}
spoon.Gesture = {
  name = 'Gesture',
  touches = {},
  config = config.__temporary__gesturesSpoon,
}

require('Spoons/Gesture.spoon/consts')
require('Spoons/Gesture.spoon/lib/init')

spoon.Gesture.cancelled = spoon.Gesture.stationary
spoon.Gesture.began = spoon.Gesture.moved

function spoon.Gesture:init()
  watcher = hs.eventtap.new(
    spoon.Gesture.types,
    ---@param event hs.eventtap.event
    function(event)
      local touches = event:getTouches() --[[@as table]]
      local fingers = #touches

      if not spoon.Gesture.fingers[tostring(fingers)] then return end

      table.each(touches, function(index, touch)
        if
          not touch or
          not spoon.Gesture.phases[touch.phase] or
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

  watcher:start()
end

return spoon.Gesture