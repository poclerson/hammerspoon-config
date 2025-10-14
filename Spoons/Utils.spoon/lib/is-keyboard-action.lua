---@param event hs.eventtap.event
---@param action KeyboardAction
function isMatchingKeys(event, action)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()
  if not flags or not keyCode or not flags:containExactly(action.keys) then return false end

  local key = table.keyOf(action.keys, hs.keycodes.map[keyCode])
  return not not key
end

---@param event Event
---@param action Action
function spoon.Utils.isKeyboardAction(event, action)
  local keyboardAction = action --[[@as KeyboardAction]]
  local keys = keyboardAction.keys

  if not keys or type(keys) ~= 'table' then return false end
  if not isMatchingKeys(event.hsEvent, keyboardAction) then return false end

  return keyboardAction
end