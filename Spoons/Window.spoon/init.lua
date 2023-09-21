---@class WindowPlacer
---@field isHeld boolean
local win = {
  name = 'Window',
  isHeld = false,
  applicationsScreens = {}
}

---Maximizes window while taking stage manager into accountName
---@param window hs.window?
local function maximizeWindow(window)
  if not window or not window:isStandard() then return end
  local max = window:screen():frame()

  window:setFrame({x=max.x, y=max.y, w=max.w * 92/100, h=max.h})
end

local function watchEvents()
  if (win.isHeld) then
    maximizeWindow(hs.application.frontmostApplication():focusedWindow())
    win.isHeld = false
  end
end

function win:init()
  local eventsWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, watchEvents)

  eventsWatcher:start()

  local defaultScreens = hs.screen.allScreens()
  local numberedScreens = {}

  hs.fnutils.eachPair(defaultScreens, function (index, screen)
    numberedScreens[index] = screen
  end)

  hs.fnutils.eachPair(ApplicationsLocation, function (app, screen)
    win.applicationsScreens[app] = numberedScreens[screen]
  end)

end

---@param name string
---@param event hs.eventtap.event
function win:watchApplications (name, event)
  if event == hs.application.watcher.launched then
    local app = hs.application.get(name)
    hs.timer.waitUntil(
      function() return app end,
      function()
        local focusedWindow = app:focusedWindow()
        maximizeWindow(app:focusedWindow())

        local appAssignedScreen = win.applicationsScreens[name]
        if appAssignedScreen then
          focusedWindow:moveToScreen(appAssignedScreen)
        end
      end
    )
    return
  end
  if event == hs.application.watcher.activated then
    local app = hs.application.get(name)
    if app then
      maximizeWindow(app:focusedWindow())
      leftClickDownWatcher = hs.eventtap.new(
        {hs.eventtap.event.types.leftMouseDown},
        function() win.isHeld = true end
      )
      leftClickDownWatcher:start()
    end
  end
end

return win