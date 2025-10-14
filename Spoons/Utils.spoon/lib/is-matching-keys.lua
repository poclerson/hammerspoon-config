---@param event hs.eventtap.event
---@param action KeyboardAction
function spoon.Utils.isMatchingKeys(event, action)
  local flags = event:getFlags()
  local keyCode = event:getKeyCode()
  if not flags or not keyCode or not flags:containExactly(action.keys) then return false end

  local key = table.keyOf(action.keys, hs.keycodes.map[keyCode])
  return not not key
end