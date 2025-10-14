---@param event Event
function dispatchAction(event)
  local hsEvent = event.hsEvent
  --TODO: allow dispatching to non-hs.eventtap.event events
  if not hsEvent then return end
  local hsEventType = event.hsEvent:getType()

  local actionType, actionSerializerConfig = table.findPair(spoon.Utils.actionsSerializerConfig, function (_, actionSerializerConfig)
    local _, correctActionSerializerHsEventType = table.find(actionSerializerConfig.types, function (_, actionSerializerHsEventType)
      return hsEventType == actionSerializerHsEventType
    end)
    return not not correctActionSerializerHsEventType
  end)
  
  if not actionType or not actionSerializerConfig then return end

  return actionSerializerConfig.verifier, actionSerializerConfig.handler
end

---@param event Event Event that triggered the action dispatcher
---@param parentConfig Json Configuration to use
---@param ... [string] Additional path to be taken in the config object. By default, the action dispatcher will look for parentConfig[event.name], and all other params will be added after
---@return boolean
function spoon.Utils.handleAction(event, parentConfig, ...)
  local unsafeSteps = {...}
  local steps = table.map(unsafeSteps, function(_, step) return tostring(step) end)
  table.insert(steps, 1, event.name)

  local configPath = steps and table.concat(steps, '.')

  local action = spoon.Utils.isAction(parentConfig, configPath)
  if not action then return false end

  if action.debug then
    print('Action ' .. action.name .. ' was triggered by the ' .. event.name ..  ' event with the following config: ', hs.inspect(action.config))
  end

  local verifier, handler = dispatchAction(event)
  if verifier then
    local isCorrectActionType = verifier(event, action)
    if not isCorrectActionType then return false end
  end

  local actionHandler = handler or spoon.Utils.triggerAction
  return actionHandler(event, action)
end