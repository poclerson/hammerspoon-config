hs.loadSpoon('EmmyLua')

require('lib')
require('hs.ipc')

MainScreen = hs.screen.find('U28E590')

Screens = hs.fnutils.mapPair(hs.screen.allScreens(), function (index, screen)
  if  #hs.screen.allScreens() == 1 or screen == MainScreen then
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
local defaultScreens = hs.screen.allScreens()
local numberedScreens = {}

hs.fnutils.eachPair(defaultScreens, function (index, screen)
  numberedScreens[index] = screen
end)

ApplicationsScreens = {}

hs.fnutils.eachPair(applicationsLocation, function (app, screen)
  ApplicationsScreens[app] = numberedScreens[screen]
end)

-- Define global variables
hs.window.animationDuration = 0

local spoons = {
  'Window',
  'Switcher',
  'StatusBar',
}

hs.fnutils.each(spoons, function (spoon)
  hs.loadSpoon(spoon)
end)

local function onApplicationEvent(name, event)
  spoon.Window:watchApplications(name, event)
end

applicationWatcher = hs.application.watcher.new(onApplicationEvent)

applicationWatcher:start()

spoon.Switcher.new('cmd', {}, {}, 'all')
