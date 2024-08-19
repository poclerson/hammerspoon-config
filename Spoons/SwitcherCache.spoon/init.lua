require('lib')
require('hs/json')

---@class SwitcherCache
---@field apps Application[]
---@field switcher Switcher
cache = {
  name = 'SwitcherCache'
}

require('Spoons/SwitcherCache.spoon/lib/init')

---Creates a new `SwitcherCache` instance
---@param switcher Switcher
---@return SwitcherCache
function cache.new(switcher)
  local apps = getAllOpenApps()
  local bundleIds = mapPair(apps, function (_, app)
    return app.instance:bundleID()
  end)
  local file = assert(io.open('cache.json', 'a+'))
  io.output(file)
  if file then
    local json = hs.json.encode(bundleIds)
    io.write(json)
    -- file:write('yoloswag')
    -- file:flush()
    -- file:close()
  end
  local self = setmetatable({
    apps = apps,
    switcher = switcher,
  }, {
    __index = cache
  })
  self.apps = apps
  return self
end

function cache.onApplicationEvent(name, event)
  local watcher = hs.application.watcher
  if event == watcher.launched then
    cache:add(name)
    cache.switcher.ui:refreshAllFrames()
  end
  if event == watcher.terminated then
    cache:removeSelected(name)
    cache.switcher.ui:refreshAllFrames()
  end
end

applicationWatcher = hs.application.watcher.new(cache.onApplicationEvent)

applicationWatcher:start()

return cache