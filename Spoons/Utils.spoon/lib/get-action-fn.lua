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