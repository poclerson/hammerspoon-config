---Open the application selected by the switcher
---@param application Application
---@return boolean?
function switcher:openSelected(application)
  if application.instance:isRunning() then
    application.instance:activate()
  else
    hs.application.open(application.name)
  end

  if not self.appsCaches then
    self.appsCaches = self:getCertainOpenApps()
  end

  local selectedAppIndex
  hs.fnutils.eachPair(self.appsCaches, function(index, cacheApp) 
    if cacheApp.name == application.name then
      selectedAppIndex = index
    end
  end)
  hs.fnutils.shift(self.appsCaches, selectedAppIndex, 1)
end