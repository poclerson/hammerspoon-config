---@param ... any
inspect = function (...)
  table.each({ ... }, function (_, value)
    local type = type(value)
    if type == 'string' or type =="nil" or type == "number" or type =="boolean" then
      print(value)
      return
    end

    print(hs.inspect(value))
  end)
end