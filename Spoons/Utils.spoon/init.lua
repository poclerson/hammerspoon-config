---@class Utils
---@field name string
spoon.Utils = {
  name = 'Utils',
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