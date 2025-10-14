---@param event Event
function spoon.Utils.isKeyboardEvent(event)
  local type = event.hsEvent:getType()
  local keyboardEventType = table.keyOf(spoon.Utils.actionsSerializerConfig.keyboard.types, type)
  return keyboardEventType
end