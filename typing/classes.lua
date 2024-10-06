---@class Application
---@field instance hs.application
---@field name string
---@field image hs.image
---@field window hs.window

---@alias Position { x: number, y: number }

---@alias ScreenChoice hs.screen|hs.screen[]|'main'|'all'

---@alias Direction 
---| 'north'
---| 'west'
---| 'south'
---| 'east'

---@alias Finger
--- | '3'
--- | '4'
--- | '5'

---@alias Color { red: number, green: number, blue: number, alpha: number? }

---@alias Json table<string, string | number | nil | boolean | [string] | table<string, Json | table<string, Json | table<string, Json | table<string, Json>>>>>

---@class Event
---@field name string
---@field direction Direction?
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
---@field direction Direction?
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

