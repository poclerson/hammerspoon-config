---@class ActionSerializer
---@field handler? fun(event: Event, action: Action): boolean
---@field verifier? fun(event: Event, action: Action): boolean
---@field types? table<number, number>

---@class Utils
---@field actionsSerializerConfig {[ActionTypes]: ActionSerializer}
spoon.Utils = {
  name = 'Utils',
  actionsSerializerConfig = {},
}

spoon.Utils.actionsSerializerConfig = {
  keyboard = { 
    verifier = function (event, action)
      return not not (spoon.Utils.isKeyboardAction(event, action) and spoon.Utils.isKeyboardEvent(event))
    end,
    types = {
      hs.eventtap.event.types['keyUp'],
      hs.eventtap.event.types['keyDown'],
      hs.eventtap.event.types['flagsChanged'],
    },
  },
}

---Creates the necessary requires for export functions
---@param filenames string[] relative path to the files
---@param path string Absolute path that will go before each file name
function spoon.Utils.createRequires(filenames, path)
  table.mapPair(filenames, function (_, filename)
    return {[string.match(filename:kebabToCamel(), "/(.*)")] = require(path .. filename)}
  end)
end

require('Spoons/Utils.spoon/lib/init')

function spoon.Utils.init()
  spoon.Utils.watchConfigEvents(config.events)
  spoon.Utils.watchConfigEvents(config.gestures)
end

return spoon.Utils