function fromHsEvent()
  
end

---@param event Event Event that triggered the action dispatcher
---@param parentConfig any Configuration to use
---@param ... [string] Additional path to be taken in the config object. By default, the action dispatcher will look for parentConfig[event.name], and all other params will be added after
---@return boolean
function spoon.Utils.handleAction(event, parentConfig, ...)
  local unsafeSteps = {...}
  local steps = table.map(unsafeSteps, function(_, step) return tostring(step) end)

  table.insert(steps, 1, event.name)

  local configPath = steps and table.concat(steps, '.')
  local action = table.get(parentConfig, configPath)
  
  if type(action) ~= 'table' then return false end

  local name = action.name
  local config = action.config
  local debug = action.debug

  if type(name) ~= 'string' then return false end

  local fn = spoon.Utils.getActionFn(name)
  if not fn or type(fn) ~= 'function' then return false end

  if debug then
    print('Action ' .. name .. ' was triggered by the ' .. event.name ..  ' event with the following config: ', hs.inspect(config))
  end

  return fn(event, config)
end