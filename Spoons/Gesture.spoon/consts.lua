---@enum (key) Fingers
local fingers <const> = {
  ['2'] = '2',
  ['3'] = '3',
  ['4'] = '4',
  ['5'] = '5',
}

---@enum (key) Phases
local phases <const> = {
  began = 'began',
  moved = 'moved',
  stationary = 'stationary',
  ended = 'ended',
  cancelled = 'cancelled',
}

local types <const> = { hs.eventtap.event.types.gesture }

spoon.Gesture.fingers = fingers
spoon.Gesture.phases = phases
spoon.Gesture.types = types