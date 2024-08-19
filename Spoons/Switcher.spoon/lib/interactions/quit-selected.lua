---Closes the application selected by the switchers
---@param app Application
function switcher:quitSelected(app)
  self.cache:removeSelected(app)
  self.ui:removeAllElements(self.ui.apps)
  self.ui:drawApps()
  self.ui:refreshAllFrames()

  if self.indexSelected == #self.cache:get() then
    self:prev()
  end
  app.instance:kill()
end