---Gets the correct screen
---@return hs.screen
function ui:getScreen()
  if self.screen == 'main' then
    return hs.screen.mainScreen()
  end
  return self.screen --[[@as hs.screen]]
end