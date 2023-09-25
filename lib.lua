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


-- TODO Cette fn marche pas, il faut trouver un moyen de reordonner une table comme il faut
-- Mais les index sont deja désordonnés
---@generic TArray : table
---@param array TArray
---@return TArray
hs.fnutils.reorder = function (array)
  local res = {}
  for i = 1, #array, 1 do
    table.insert(res, value)
  end
  -- printTable(res)
  return res
end

---Gets all the open apps under a specific format
---@param asSet boolean? Defaults to true. If true, there will be no duplicates
---@return Application[]
getAllOpenApps = function (asSet)
  if asSet == nil then
    asSet = true
  end
  local windows = hs.window.allWindows()

  appsFormatted = {}

  hs.fnutils.eachPair(windows, function (index, window)
    local app = window:application()
    local appFormatted = {
      name = app:name(),
      image = hs.image.imageFromAppBundle(app:bundleID()),
      instance = app,
      window = window,
    }
    appsFormatted[index] = appFormatted
  end)
  if not asSet then
    return appsFormatted
  end
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