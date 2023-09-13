require('lib')

MainScreen = hs.screen.find('U28E590')

Screens = map(hs.screen.allScreens(), function (index, screen)
  if screen == MainScreen then
    return {['main'] = screen}
  end
  return {['screen'..index - 1] = screen}
end)

-- Base window layout configuration
local applicationsLocation = {
  Spotify = 3,
  Discord = 3,
  Mattermost = 3,
  Messenger = 3,
  DevPod = 3,
  Hammerspoon = 3,
  Code = 2,
}

--[[
  Map all the applications location to their respective screen
  Maps under this format:
  ApplicationsScreens[applicationName] = screen UUID
]]
defaultScreens = hs.screen.allScreens()
numberedScreens = {}

for index, screen in pairs(defaultScreens) do
  numberedScreens[index] = screen
end

ApplicationsScreens = {}

for app, screen in pairs(applicationsLocation) do
  ApplicationsScreens[app] = numberedScreens[screen]
end

-- Define global variables
hs.window.animationDuration = 0

KeyCodes = {
  q = 12,
  w = 13,
  num1 = 18,
  num2 = 19,
  num3 = 20,
  num4 = 21,
  num5 = 22,
  num6 = 23,
  esc = 53,
  m = 46,
  tab = 48,
  ugrave = 50,
}

SwitcherKeyBinds = {
  quitSelected = KeyCodes.q,
  minimizeSelected = KeyCodes.m,
  closeAllWindowsOfSelected = KeyCodes.w,
  selectNext = KeyCodes.tab,
  selectPrev = KeyCodes.ugrave,
  closeSwitcher = KeyCodes.esc,
  moveSelectedToScreen = {
    main = KeyCodes.num1,
    screen1 = KeyCodes.num2,
    screen2 = KeyCodes.num3,
  }
}

local spoons = {
  'Utils',
  'Window',
  'Switcher',
}

each(spoons, function (index, spoon)
  hs.loadSpoon(spoon)
end)

local function onApplicationEvent(name, event)
  spoon.Window:watchApplications(name, event)
end

applicationWatcher = hs.application.watcher.new(onApplicationEvent)

applicationWatcher:start()