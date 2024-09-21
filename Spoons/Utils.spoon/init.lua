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

---@param name string
---@return (fun(event: Event?, config: EventConfig): boolean) | nil
function spoon.Utils.getActionFn(name)
  local steps = name:split('.')
  local spoonName = steps[1]

  if spoonName:startswith('hs') then
    local hsPath = table.remove(steps, 1)
    local fn = table.get(hs, table.concat(hsPath, '.'))

    return fn
  end

  local functionName = steps[#steps]
  local loadedSpoon = spoon[spoonName] or hs.loadSpoon(spoonName)
  if not loadedSpoon or type(loadedSpoon) ~= 'table' then return nil end
  local fn = loadedSpoon[functionName]

  return fn
end

---@param event Event Event that triggered the action dispatcher
---@param parentConfig any Configuration to use
---@param ... [string] Additional path to be taken in the config object. By default, the action dispatcher will look for parentConfig[event.name]
---@return boolean
function spoon.Utils.actionDispatcher(event, parentConfig, ...)
  local unsafeSteps = {...}
  local steps = table.map(unsafeSteps, function(_, step) return tostring(step) end)

  table.insert(steps, #steps + 1, event.name)

  local configPath = steps and table.concat(steps, '.')
  local action = table.get(parentConfig, configPath)
  
  if type(action) ~= 'table' then return false end

  local name = action.name
  local config = action.config

  if type(name) ~= 'string' or type(config) ~= 'table' then return false end

  local fn = spoon.Utils.getActionFn(name)
  if not fn or type(fn) ~= 'function' then return false end

  return fn(event, config)
end

return spoon.Utils