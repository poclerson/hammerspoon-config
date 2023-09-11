-- Define global variables
hs.window.animationDuration = 0

KeyCodes = {
  q = 12,
  w = 13,
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
  closeSwitcher = KeyCodes.esc
}

-- Base window layout configuration
local applicationsLocation = {
  Spotify = 3,
  Discord = 3,
  Mattermost = 3,
  Messenger = 3,
  DevPod = 3,
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

local spoons = {
  'Utils',
  'Window',
  'Switcher',
}

for _, spoon in pairs(spoons) do
  hs.loadSpoon(spoon)
end

local function onApplicationEvent(name, event)
  spoon.Window:watchApplications(name, event)
end

applicationWatcher = hs.application.watcher.new(onApplicationEvent)

applicationWatcher:start()

function reloadConfig(paths, force)
  print('Config reloaded')
  applicationWatcher:stop()
  applicationWatcher = nil
end