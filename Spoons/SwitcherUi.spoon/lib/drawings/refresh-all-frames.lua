---@param removedApp hs.application?
function ui:refreshAllFrames(removedApp)
  self:eachCanvas(function (_, canvas)
    canvas:frame(self:position(removedApp))
  end)
end