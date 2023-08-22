IsWindowHeld = false

local function maximizeWindow(window)
  local max = window:screen():frame()

  window:setFrame({x=max.x, y=max.y, w=max.w * 92/100, h=max.h})
end

-- Redimenssionne toutes les applications à la bonne taille de l'écran
local function watchApplications(name, event)
  if (event == hs.application.watcher.activated) then
    local app = hs.application.get(name)

    local leftClickDownWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function() IsWindowHeld = true end)
    leftClickDownWatcher:start()
  end
end

local function watchEvents(event) 
  if (IsWindowHeld) then
    maximizeWindow(hs.application.frontmostApplication():focusedWindow())
  end
end

local eventsWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, watchEvents)
local applicationWatcher = hs.application.watcher.new(watchApplications)

applicationWatcher:start()
eventsWatcher:start()