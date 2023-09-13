eachPair = function (array, fn)
  for key, value in pairs(array) do
    fn(key, value)
  end
  return array
end

each = function (array, fn)
  for i = 1, #array, 1 do
    fn(i, array[i])
  end
  return array
end

map = function (array, fn)
  local res = {}
  for key, value in pairs(array) do
    for nestedKey, nestedValue in pairs(fn(key, value)) do
      res[nestedKey] = nestedValue
    end
  end
  return res
end

transfer = function (arrayFrom, arrayTo, fn)
  for key, value in pairs(arrayFrom) do
    for nestedKey, nestedValue in pairs(fn(key, value)) do
      arrayTo[nestedKey] = nestedValue
    end
  end
end

filter = function (array, fn)
  local res = {}
  for key, value in ipairs(array) do
    if fn(key, value) then
      res[key] = value
    end
  end
  return res
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
    if fn(key, value) then
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
  return array
end

moveToStart = function (array, fn)
  removeIfContains(array, fn)

  insertIfContains(array, fn)
end

keyByValue = function (array, valueOfKey)
  local res = nil
  eachPair(array, function (key, value)
    if key == valueOfKey then
      res = valueOfKey
    end
  end)
  return res
end

printTable = function(array)
  if array == nil then
    print('not a table')
    return
  end
  eachPair(array, function (index1, value1)
    -- if type(value) == 'array' then
    --   eachPair(value, function (index2, value2)
    --     print(index2, value2)
    --   end)
    -- end
    print(index1, value1)
  end)
end