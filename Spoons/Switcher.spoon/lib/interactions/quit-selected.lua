---Closes the application selected by the switchers
---@param application Application
function switcher:quitSelected(application)
  self.appsCaches = hs.fnutils.filterPair(self.appsCaches, function(_, cacheApp)
    return application.name ~= cacheApp.name
  end)
  self.ui:removeAllElements(self.ui.apps)
  self.ui:drawApps()
  self.ui:refreshAllFrames()

  if self.indexSelected == #self:getCertainOpenApps() then
    self:prev()
  end
  application.instance:kill()
end