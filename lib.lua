---Executes `fn` for every element of `array` in key-value array
---@param array table
---@param fn function
---@return table
eachPair = function (array, fn)
  for key, value in pairs(array) do
    fn(key, value)
  end
  return array
end

---Executes `fn` for every element of `array` in ordered array
---@param array table
---@param fn function
---@return table
each = function (array, fn)
  for i = 1, #array, 1 do
    fn(i, array[i])
  end
  return array
end

---Returns executed `fn` for every `array` member
---@param array table
---@param fn function
---@return table
map = function (array, fn)
  local res = {}
  for key, value in pairs(array) do
    local fnResult = fn(key, value)
    if fnResult == nil then
      error('not a table, nil')
    end
    if type(fnResult) ~= 'table' then
      res[key] = fnResult
    else
      for nestedKey, nestedValue in pairs(fnResult) do
        res[nestedKey] = nestedValue
      end
    end
  end
  return res
end

---Removes every `array` member on which the test `fn` returns false
---@param array table
---@param fn function
---@return table
filter = function (array, fn)
  local res = {}
  for key, value in ipairs(array) do
    if fn(key, value) then
      res[key] = value
    end
  end
  return res
end

---Removes duplicates from a table
---@param array table
---@return table
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

---Checks if any member of `array` satisfies `fn`
---@param array table
---@param fn function
---@return boolean
contains = function (array, fn)
  local doesContain = false
  eachPair(array, function (key, value)
    doesContain = fn(key, value)
  end)
  return doesContain
end

---Performs `table.insert` on `array` on every `array` member that satisfies the test `fn`
---@param array table
---@param fn function
---@return boolean
insertIfContains = function (array, fn)
  local doesContain = false
  eachPair(array, function (key, value)
    if fn(value) then
      doesContain = true
      table.insert(array, value)
    end
  end)
  return doesContain
end

---Removes any `array` member that satisfies the test `fn`
---@param array table
---@param fn function
---@return table
removeIfContains = function (array, fn)
  eachPair(array, function (key, value)
    if fn(value) then
      array[key] = nil
    end
  end)
  return array
end

---Moves every `array` member that satisfies the test `fn` to the start of `array`
---@param array table
---@param fn function
moveToStart = function (array, fn)
  removeIfContains(array, fn)

  insertIfContains(array, fn)
end

---Returns the key of a value in `array`
---@param array any
---@param valueOfKey any
---@return nil|any
keyByValue = function (array, valueOfKey)
  local res = nil
  eachPair(array, function (key, value)
    if key == valueOfKey then
      res = valueOfKey
    end
  end)
  return res
end

---Prints a table
---@param array table
---@param printNested boolean? Defaults to true
---@param printStacktrace boolean? Defaults to false
printTable = function(array, printNested, printStacktrace)
  if printNested == nil then
    printNested = true
  end
  if printStacktrace then
    print(debug.traceback())
  end
  if type(array) ~= 'table' then
    print('not a table, but a '..type(array), array)
    return
  end
  if array == nil then
    print('variable is nil')
    return
  end
  eachPair(array, function (key, value)
    print(key, value)
    if type(value) == 'table' and printNested then
      print('{')
      eachPair(value, function (nestedKey, nestedValue)
        print('  ', nestedKey, nestedValue)
      end)
      print('}')
    end
  end)
end