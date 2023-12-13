---@param index number?
function ui:drawComponents(index)
  self:drawBackground()
  self:drawSelection(index or 1)
  self:drawApps()
end