require('lib')
hs.loadSpoon('Utils')

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

local spoons = {
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

spoon.Switcher.new('alt', {}, {}, 'main')