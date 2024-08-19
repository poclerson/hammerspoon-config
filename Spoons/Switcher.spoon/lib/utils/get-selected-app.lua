---@return Application?
function switcher:getSelectedApp() 
  return self.cache:get()[self.indexSelected]
end