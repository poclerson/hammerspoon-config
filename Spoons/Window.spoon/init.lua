local spoon = {
  name = 'Window'
}

function spoon:start()
  IsWindowHeld = false

  local eventsWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, watchEvents)
  local applicationWatcher = hs.application.watcher.new(watchApplications)

  applicationWatcher:start()
  eventsWatcher:start()
end

-- Maximizes window while taking stage manager into account
function maximizeWindow(window)
  if (not window) then
    return
  end
  local max = window:screen():frame()

  window:setFrame({x=max.x, y=max.y, w=max.w * 92/100, h=max.h})
end

-- Applications events listener
function watchApplications(name, event)
  local app = hs.application.get(name)
  if (event == hs.application.watcher.activated) then
    if app then
      maximizeWindow(app:focusedWindow()) 
      local leftClickDownWatcher = hs.eventtap.new(
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