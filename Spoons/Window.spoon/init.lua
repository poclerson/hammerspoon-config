local spoon = {
  name = 'Window'
}

function spoon:start()
  IsWindowHeld = false

  eventsWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, watchEvents)

  eventsWatcher:start()

  hs.loadSpoon('Monitors')
end

-- Maximizes window while taking stage manager into account
function maximizeWindow(window)
  if not window then return end
  local max = window:screen():frame()

  window:setFrame({x=max.x, y=max.y, w=max.w * 92/100, h=max.h})
end

-- Applications events listener
function spoon:watchApplications (name, event)
  if event == hs.application.watcher.launched then
    local app = hs.application.get(name)
    hs.timer.waitUntil(
      function() return app end,
      function()
        local focusedWindow = app:focusedWindow()
        maximizeWindow(app:focusedWindow())

        local appAssignedScreen = ApplicationsScreens[name]
        if appAssignedScreen then
          focusedWindow:moveToScreen(appAssignedScreen)
        end
      end
    )
  end
  if event == hs.application.watcher.activated then
    local app = hs.application.get(name)
    if app then
      maximizeWindow(app:focusedWindow())
      leftClickDownWatcher = hs.eventtap.new(
        {hs.eventtap.event.types.leftMouseDown},
        function() IsWindowHeld = true end
      )
      leftClickDownWatcher:start()
    end
  end
end

-- Keyboard/mouse events listener
function watchEvents(event)
  if (IsWindowHeld) then
    maximizeWindow(hs.application.frontmostApplication():focusedWindow())
    IsWindowHeld = false
  end
end

return spoon