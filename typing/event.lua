---@class Event
---@field name string
---@field direction Directions?
---@field hsEvent (hs.eventtap.event | nil)?

---@alias EventConfig
---| Window.Place
---| Window.Move

---@class Window.Place
---@field name 'place'
---@field x number?
---@field y number?
---@field w number?
---@field h number?
---@field duration number?

---@class Window.Move
---@field name 'move'
---@field direction Directions?
---@field duration number?

---@alias ActionTypes
---| 'keyboard'
---| 'gesture'
---| 'mouse'
---| 'window'
---| 'default'

---@class Action
---@field name string?
---@field config EventConfig?
---@field debug boolean?

---@class KeyboardAction : Action
---@field keys table<number, string>