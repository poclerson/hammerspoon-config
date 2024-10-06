---@param name string
---@return (fun(event: Event, action: Action): boolean) | nil
function getActionFn(name)
  local steps = name:split('.')
  local spoonName = steps[1]

  if spoonName:startswith('hs') then
    local hsPath = table.remove(steps, 1)
    local fn = table.get(hs --[[@as table]], table.concat(hsPath, '.'))

    return fn
  end

  local functionName = steps[#steps]
  local loadedSpoon = spoon[spoonName] or hs.loadSpoon(spoonName)
  if not loadedSpoon or type(loadedSpoon) ~= 'table' then return nil end
  local fn = loadedSpoon[functionName]

  return fn
end

---@param event Event
---@param action Action
function spoon.Utils.triggerAction(event, action)
  local actionFn = getActionFn(action.name)
  if not actionFn or type(actionFn) ~="function" then return false end

  return actionFn(event, action)
end