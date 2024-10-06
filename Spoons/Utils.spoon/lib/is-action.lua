---@param parentConfig Json
---@param configPath string
---@return Action | nil
function spoon.Utils.isAction(parentConfig, configPath)
  local action = table.get(parentConfig, configPath)
  if not action then return nil end

  local isTable = type(action) == 'table'
  local hasName = type(action.name) == 'string'
  local hasValidConfig = type(action.config) == 'table' or not action.config

  if not isTable or not hasName or not hasValidConfig then return nil end

  return action
end