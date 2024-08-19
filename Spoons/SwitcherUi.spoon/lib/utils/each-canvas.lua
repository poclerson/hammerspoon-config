---@param fn function
function ui:eachCanvas(fn)
  hs.fnutils.eachPair(self.components, function (name, canvas)
    fn(name, canvas)
  end)
end
