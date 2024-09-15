---@class Swiper
---@field name string
---@field type string
---@field watcher hs.eventtap | nil
---@field directions {[Direction]: Direction}
---@field fingers [Finger]
---@field touches {[string]: [DistanceReturn]}
Swipe = {
  name = 'Swipe',
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
  previous = nil,
  touches = {},
}

require('Spoons/Swipe.spoon/lib/init')

Swipe.cancelled = Swipe.stationary
Swipe.began = Swipe.moved

function Swipe:init()
  self.watcher = hs.eventtap.new(
    { self.type }, 
    ---@param event hs.eventtap.event
    function(event)
      local touches = event:getTouches() --[[@as table]]
      local fingers = #touches

      if fingers <= 2 then return end

      table.each(touches, function(index, touch)
        
        if
          not table.some({ 'began', 'moved', 'stationary', 'ended', 'cancelled' }, function (_, value) return touch.phase == value end) or
          not touch or
          not touch.identity
        then
          return end

        if not Swipe[touch.phase] or type(Swipe[touch.phase]) ~= 'function' or not touch or type(touch) ~= 'table' then return end

        local result = Swipe[touch.phase](touch, index) or {}
        local direction = result.direction

        if touch.phase ~= 'ended' or not direction then return end

        spoon.Utils.actionDispatcher({ direction = direction }, Config.swipe, direction, fingers)
      end)
    end
  )

  self.watcher:start()
end

return Swipe