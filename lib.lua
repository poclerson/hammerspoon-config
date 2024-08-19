---@diagnostic disable: duplicate-set-field, inject-field

---Executes `fn` for every element of `array` in key-value array
---@generic TKey
---@generic TValue
---@param array {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue)
---@return {[TKey]: TValue}
hs.fnutils.eachPair = function (array, fn)
  for key, value in pairs(array) do
    fn(key, value)
  end
  return array
end

---Returns executed `fn` for every `array` member
---@generic TKey
---@generic TValue
---@generic TReturn : table
---@param array {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue): TReturn
---@return table
hs.fnutils.mapDeepPair = function (array, fn)
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

---Returns executed `fn` for every `array` member
---@generic TKey
---@generic TValue
---@generic TReturn : table
---@param array {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue): TReturn
---@return table
hs.fnutils.mapPair = function (array, fn)
  local res = {}
  for key, value in pairs(array) do
    local fnResult = fn(key, value)
    if fnResult == nil then
      error('not a table, nil')
    end
    res[key] = fnResult
  end
  return res
end

---Returns all `array` members that pass the test `fn`
---@generic TKey
---@generic TValue
---@param array {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue): boolean
---@return {[TKey]: TValue}
hs.fnutils.filterPair = function (array, fn)
  local res = {}
  for key, value in pairs(array) do
    if fn(key, value) then
      res[key] = value
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

---Removes elements with duplicate keys from a table
---@generic TKey
---@generic TValue
---@param array {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue): any
---@return {[TKey]: TValue}
hs.fnutils.toSetPair = function(array, fn)
  hash = {}
  res = {}
  hs.fnutils.eachPair(array, function (index, value)
    if not hash[fn(index, value)] then
      res[#res+1] = value
      hash[fn(index, value)] = true
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
  hs.fnutils.removeIfContains(array, fn)

  hs.fnutils.insertIfContains(array, fn)
end

---Sorts a numbered table `array`
---@generic TArray: {[number]: table}
---@param array TArray
---@return TArray
hs.fnutils.reorder = function (array)
  local arrayWithIndexes = hs.fnutils.mapPair(array, function (key, value)
    value.index = key
    return value
  end)
  table.sort(arrayWithIndexes, function (current, next)
    if not next then
      return true
    end
    return current.index < next.index
  end)
  return arrayWithIndexes
end

---Moves item at position `old` to position `new` in table `array`
---@generic TKey
---@param array {[TKey]: any}
---@param old TKey
---@param new TKey
hs.fnutils.shift = function(array, old, new)
  local value = array[old]
  if new < old then
     table.move(array, new, old - 1, new + 1)
  else    
     table.move(array, old + 1, new, old) 
  end
  array[new] = value
end

---Gets all the open apps under a specific format
---@param asSet boolean? Defaults to true. If true, there will be no duplicates
---@return Application[]
getAllOpenApps = function (asSet)
  if asSet == nil then
    asSet = true
  end
  local windows = hs.window.allWindows()

  ---@type Application[]
  appsFormatted = {}

  hs.fnutils.eachPair(windows, function (index, window)
    local app = window:application() --[[@as hs.application]]
    local appFormatted = {
      name = app:name(),
      image = hs.image.imageFromAppBundle(app:bundleID()),
      instance = app,
      window = window,
    }
    appsFormatted[index] = appFormatted
  end)
  local appsFiltered = hs.fnutils.filterPair(appsFormatted, function (_, app)
    return not (app.name == 'Hammerspoon' and not app.window:isStandard())
  end) --[[@as Application[] ]]
  if not asSet then
    return appsFiltered
  end
  return hs.fnutils.toSet(appsFiltered)
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

---Converts a string of kebab case to camel case
---@param str string
---@return string
kebabToCamel = function(str)
  local previousChar
  local newStr
  for char in str:gmatch'.' do
    if char ~= '-' then
      if previousChar == '-' then
        newStr = newStr .. string.upper(char)
      else
        newStr = (newStr or '') .. char
      end
    end
    previousChar = char
  end
  return newStr
end

---Creates the necessary requires for export functions
---@param filenames string[] relative path to the files
---@param path string Absolute path that will go before each file name
createRequires = function(filenames, path)
  hs.fnutils.mapPair(filenames, function (_, filename)
    return {[string.match(kebabToCamel(filename), "/(.*)")] = require(path .. filename)}
  end)
end