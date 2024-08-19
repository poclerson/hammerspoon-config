---@param removedAppName string
function cache:removeSelected(removedAppName)
  removeIfContains(self.apps, function (_, app)
    return removedAppName == app.name
  end)
end