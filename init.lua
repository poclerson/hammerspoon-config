-- Define global variables
hs.window.animationDuration = 0

local spoons = {
  'Window',
}

for _, spoon in pairs(spoons) do
  hs.loadSpoon(spoon):start()
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