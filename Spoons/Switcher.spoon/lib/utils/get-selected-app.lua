---@return Application?
function switcher:getSelectedApp() 
  return self:getCertainOpenApps()[self.indexSelected]
end