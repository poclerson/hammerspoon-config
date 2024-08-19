local function searcher(module_name)
  -- Use "/" instead of "." as directory separator
  local path, err = package.searchpath(module_name, package.path, "/")
  if path then
    return loadfile(path)
  end
  return err
end

table.insert(package.searchers, searcher)

require('lib')
require('hs.ipc')

-- Define global variables
hs.window.animationDuration = 0

MainScreen = hs.screen.find('U28E590')

Screens = mapPair(hs.screen.allScreens(), function (index, screen)
  if  #hs.screen.allScreens() == 1 or screen == MainScreen then
    return {['main'] = screen}
  end
  return {['screen'..index - 1] = screen}
end)

-- Base window layout configuration
ApplicationsLocation = {
  Spotify = 3,
  Discord = 3,
  Mattermost = 3,
  Messenger = 3,
  DevPod = 3,
  Hammerspoon = 3,
  Code = 2,
}

local spoons = {
  'Window',
}

each(spoons, function (_, spoon)
  hs.loadSpoon(spoon)
end)

local function onApplicationEvent(name, event)
  eachPair(spoon, function (_, currentSpoon)
    if not currentSpoon or not currentSpoon['watchApplications'] then
      return
    end
    currentSpoon:watchApplications(name, event)

  end)
end

applicationWatcher = hs.application.watcher.new(onApplicationEvent)

applicationWatcher:start()
