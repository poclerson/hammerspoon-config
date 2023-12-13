---@param removedApp hs.application?
function ui:drawBackground(removedApp)
  local component = self.style.background

  self.background:frame(self:position(removedApp))
  self.background:appendElements({
    type = 'rectangle',
    frame = self.generic.fillFrame,
    flatness = 1,
    fillColor = component.fillColor,
    roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
    strokeWidth = component.strokeWidth,
    strokeColor = component.strokeColor,
  })
end