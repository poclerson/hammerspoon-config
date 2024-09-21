---@type any
Config = hs.json.read('config.json')

assert(Config and type(Config) == "table")

local function searcher(module_name)
  -- Use "/" instead of "." as directory separator
  local path, err = package.searchpath(module_name, package.path, "/")
  if path then
    return loadfile(path)
  end
  return err
end

table.insert(package.searchers, searcher)

require('lib-table')
require('lib-string')
require('hs.ipc')

-- Define global variables
hs.window.animationDuration = 0

local spoons = {
  'Utils',
  'Window',
  'Swipe',
}

table.each(spoons, function (_, spoon)
  hs.loadSpoon(spoon)
end)
