---@param fn function
function ui:eachCanvas(fn)
  eachPair(self.components, function (name, canvas)
    fn(name, canvas)
  end)
end
