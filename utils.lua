eachPair = function (table, fn)
  for key, value in pairs(table) do
    fn(key, value)
  end
end

each = function (table, fn)
  for i = 1, #table, 1 do
    fn(i, table[i])
  end
end

toSet = function (table)
  hash = {}
  res = {}
  each(table, function (key, value)
    if not hash[value.name] then
      res[#res+1] = value
      hash[value.name] = true
    end
  end)
  return res
end

printTable = function(table)
  eachPair(table, function (index, value)
    print(index, value)
  end)
end