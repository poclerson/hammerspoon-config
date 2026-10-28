---@class Event
---@field name string
---@field direction Directions?
---@field hsEvent (hs.eventtap.event | nil)?
---@field window (hs.window | nil)?

---@alias EventConfig
---| Window.Place
---| Window.Move

---@class Window.Place
---@field name 'Window.place'
---@field x number?
---@field y number?
---@field w number?
---@field h number?
---@field duration number?

---@class Window.Move
---@field name 'Window.move'
---@field direction Directions?
---@field duration number?

---@alias Directions
---| 'north'
---| 'east'
---| 'south'
---| 'west'

---@class Action
---@field name string
---@field config EventConfig?
---@field debug boolean?

---@class KeyboardAction : Action
---@field keys table<number, string>
