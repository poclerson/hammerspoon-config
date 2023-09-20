---@diagnostic disable: duplicate-set-field, inject-field

---Executes `fn` for every element of `array` in key-value array
---@param array table
---@param fn function
---@return table
hs.fnutils.eachPair = function (array, fn)
  for key, value in pairs(array) do
    fn(key, value)
  end
  return array
end

---Returns executed `fn` for every `array` member
---@param array table
---@param fn function
---@return table
hs.fnutils.mapPair = function (array, fn)
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

---Removes duplicates from a table
---@param array table
---@return table
hs.fnutils.toSet = function (array)
  hash = {}
  res = {}
  hs.fnutils.each(array, function (value)
    if not hash[value.name] then
      res[#res+1] = value
      hash[value.name] = true
    end
  end)
  return res
end

---Performs `table.insert` on `array` on every `array` member that satisfies the test `fn`
---@param array table
---@param fn function
---@return boolean
hs.fnutils.insertIfContains = function (array, fn)
  local doesContain = false
  hs.fnutils.each(array, function (value)
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
hs.fnutils.removeIfContains = function (array, fn)
  hs.fnutils.eachPair(array, function (key, value)
    if fn(value) then
      array[key] = nil
    end
  end)
  return array
end

---Moves every `array` member that satisfies the test `fn` to the start of `array`
---@param array table
---@param fn function
hs.fnutils.moveToStart = function (array, fn)
  removeIfContains(array, fn)

  insertIfContains(array, fn)
end

---Gets all the open apps under a specific format
---@return table
getAllOpenApps = function ()
  local windows = hs.window.allWindows()

  appsFormatted = {}

  hs.fnutils.eachPair(windows, function (index, window)
    local app = window:application()
    local appFormatted = {
      name = app:name(),
      image = hs.image.imageFromAppBundle(app:bundleID()),
      instance = app,
    }
    appsFormatted[index] = appFormatted
  end)
  return hs.fnutils.toSet(appsFormatted)
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
  hs.fnutils.eachPair(array, function (key, value)
    print(key, value)
    if type(value) == 'table' and printNested then
      print('{')
      hs.fnutils.eachPair(value, function (nestedKey, nestedValue)
        print('  ', nestedKey, nestedValue)
      end)
      print('}')
    end
  end)
end