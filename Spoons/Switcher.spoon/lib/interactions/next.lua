function switcher:next()
  if self.isOpen then
    self.indexSelected = self.indexSelected + 1
    if self.indexSelected > #self:getCertainOpenApps() then
      self.indexSelected = 1
    end
    self.ui:drawSelection(self.indexSelected)
    return
  end

  if not self.appsCaches then
    self.appsCaches = self:getCertainOpenApps()
  end

  self.isOpen = true
  self.indexSelected = 1
  self.currentScreen = hs.screen.mainScreen()

  self.ui:drawSelection()
  self.ui:removeAllElements(self.ui.apps)
  self.ui:drawApps()
  self.ui:refreshAllFrames()
  self.ui:showComponents()
end