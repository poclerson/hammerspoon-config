---@param canvas hs.canvas
function ui:removeAllElements(canvas)
  hs.fnutils.each(canvas, function ()
    canvas:removeElement()
  end)
end