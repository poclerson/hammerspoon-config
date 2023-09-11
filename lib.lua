eachPair = function (array, fn)
  for key, value in pairs(array) do
    fn(key, value)
  end
end

each = function (array, fn)
  for i = 1, #array, 1 do
    fn(i, array[i])
  end
end

toSet = function (array)
  hash = {}
  res = {}
  each(array, function (key, value)
    if not hash[value.name] then
      res[#res+1] = value
      hash[value.name] = true
    end
  end)
  return res
end

contains = function (array, fn)
  doesContain = false
  eachPair(array, function (key, value)
    if fn(value) then
      doesContain = true
    end
  end)
  return doesContain
end

insertIfContains = function (array, fn)
  eachPair(array, function (key, value)
    if fn(value) then
      table.insert(array, value)
    end
  end)
end

removeIfContains = function (array, fn)
  eachPair(array, function (key, value)
    if fn(value) then
      array[key] = nil
    end
  end)
end

moveToStart = function (array, fn)
  removeIfContains(array, fn)

  insertIfContains(array, fn)
end

printTable = function(array)
  eachPair(array, function (index1, value1)
    -- if type(value) == 'array' then
    --   eachPair(value, function (index2, value2)
    --     print(index2, value2)
    --   end)
    -- end
    print(index1, value1)
  end)
end