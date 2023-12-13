---@param index number?
function ui:drawSelection(index)
  local style = self.style
  local component = self.style.selection

  self.selection:appendElements({
    type = 'rectangle',
    action = 'skip'
  })
  self.selection:replaceElements({
    type = 'rectangle',
    frame = {
      x =  style.padding / 2 + ((style.appWidth + style.padding) * ((index or 1) - 1)),
      y = style.padding / 2,
      w = style.padding + style.appWidth,
      h = style.padding + style.appWidth,
    },
    flatness = 1,
    fillColor = component.fillColor,
    roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
    strokeWidth = component.strokeWidth,
    strokeColor = component.strokeColor,
  })
end