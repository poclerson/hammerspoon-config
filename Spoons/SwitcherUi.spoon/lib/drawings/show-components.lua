function ui:showComponents()
  self:eachCanvas(function (name, canvas)
    canvas:show()
  end)
end