function resizer:onLeftMouse(event)
  local eventType = event:getType()

  if eventType == hs.eventtap.event.types.leftMouseUp then
    resizer:maximizeWindow(hs.application.frontmostApplication():focusedWindow())
  end
end