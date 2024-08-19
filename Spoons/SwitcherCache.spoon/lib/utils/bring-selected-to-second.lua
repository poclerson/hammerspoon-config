---@param selectedApp Application
function cache:bringSelectedToSecond(selectedApp)
  local selectedAppIndex = indexOf(self.apps, selectedApp)

  shift(self.apps, selectedAppIndex, 2)
end