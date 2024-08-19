---@param appName string
function cache:add(appName)
  local app = createApp(appName)
  table.insert(self.apps, #self.apps + 1, app)
end