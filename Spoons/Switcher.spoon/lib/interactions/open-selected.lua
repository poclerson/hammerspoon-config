---Open the application selected by the switcher
---@param app Application
---@return boolean?
function switcher:openSelected(app)
  if app.instance:isRunning() then
    app.instance:activate()
  else
    hs.application.open(app.name)
  end

  self.cache:bringSelectedToSecond(app)
end