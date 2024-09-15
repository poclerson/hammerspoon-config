function spoon.Window.onLeftMouse(event)
  local eventType = event:getType()

  if eventType == hs.eventtap.event.types.leftMouseUp then
    spoon.Window.place(Config.window.maximize)
  end
end