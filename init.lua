---@type any
config = hs.json.read('config.json')

assert(config and type(config) == "table")

local function searcher(module_name)
  -- Use "/" instead of "." as directory separator
  local path, err = package.searchpath(module_name, package.path, "/")
  if path then
    return loadfile(path)
  end
  return err
end

table.insert(package.searchers, searcher)

require('hs.ipc')

-- Define global variables
hs.window.animationDuration = 0

hs.loadSpoon('Window')
hs.loadSpoon('Gesture')
