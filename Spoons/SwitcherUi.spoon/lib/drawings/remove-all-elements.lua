---@param canvas hs.canvas
function ui:removeAllElements(canvas)
  each(canvas, function ()
    canvas:removeElement()
  end)
end