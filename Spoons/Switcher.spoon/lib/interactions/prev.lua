function switcher:prev()
  self.indexSelected = self.indexSelected - 1
  if self.indexSelected < 1 then
    self.indexSelected = #self:getCertainOpenApps()
  end
  self.ui:drawSelection(self.indexSelected)
end