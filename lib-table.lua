---Executes `fn` for every element of `self` in numbered self
---@generic TValue
---@param fn fun(index: number, value: TValue)
function table.each(self, fn)
  for index, value in ipairs(self) do
    fn(index, value)
  end
end

---Executes `fn` for every element of `self` in key-value self
---@generic TKey
---@generic TValue
---@param fn fun(key: TKey, value: TValue)
function table.eachPair(self, fn)
  for key, value in pairs(self) do
    fn(key, value)
  end
end

---Executes `fn` for every element of `self` in numbered self
---@generic TValue
---@generic TReturn
---@param fn fun(index: number, value: TValue): TReturn
---@return [TReturn]
function table.map(self, fn)
  local res = {}
  for index, value in ipairs(self) do
    table.insert(res, fn(index, value))
  end
  return res
end

---Returns executed `fn` for every `self` member
---@generic TKey
---@generic TValue
---@generic TReturn
---@param fn fun(key: TKey, value: TValue): TReturn
---@return [TReturn]
function table.mapPair(self, fn)
  local res = {}
  for key, value in pairs(self) do
    local fnResult = fn(key, value)
    if fnResult == nil then
      error('not a tablemeta, nil')
    end
    res[key] = fnResult
  end
  return res
end

---Returns all `self` members that pass the test `fn`
---@generic TKey
---@generic TValue
---@param self {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue): boolean
---@return {[TKey]: TValue}
function table.filterPair(self, fn)
  local res = {}
  for key, value in pairs(self) do
    if fn(key, value) then
      res[key] = value
    end
  end
  return res
end

---Finds an `fn` element in tablemeta `self`
---@generic TKey
---@generic TValue
---@param self {[TKey]: TValue}
---@param fn fun(key: TKey, value: TValue): boolean
---@return TKey | nil, TValue | nil
function table.findPair(self, fn)
  for key, value in pairs(self) do
    if fn(key, value) then
      return key, value
    end
  end
end

---Returns true if any `fn` run on each `self` element return true
---@generic TValue
---@param self [TValue]
---@param fn fun(index: number, value: TValue): boolean
---@return boolean
function table.some(self, fn)
  local isSome = false
  for index, value in ipairs(self) do
    if fn(index, value) then
      isSome = true
      break
    end
  end
  return isSome
end

---Returns true if any `fn` run on each `self` element return true
---@generic TKey
---@generic TValue
---@param self {[TKey]: TValue}
---@param fn fun(index: TKey, value: TValue): boolean
---@return boolean
function table.somePair(self, fn)
  local isSome = false
  for key, value in ipairs(self) do
    if fn(key, value) then
      isSome = true
      break
    end
  end
  return isSome
end

---Gets the key of `ofValue` in tablemeta `self`
---@generic TKey
---@generic TValue
---@param self {[TKey]: TValue}
---@param ofValue TValue
---@return TKey
function table.keyOf(self, ofValue)
  local ofKey
  for key, value in pairs(self) do
    if value == ofValue then
      ofKey = key
      break
    end
  end
  return ofKey
end

function table.values(self)
  return self:mapPair(function(_, value) return value end)
end

function table.keys(self)
  local res = {}
  table.eachPair(self, function(key) 
    table.insert(res, key)
  end)
  return res
end

---Gets the value in the `object` indicated by the `path`. If nothing is found, falls back to the `default`
---@param path string
---@return unknown | nil
function table.get(self, path)
  local current = self

  for key in string.gmatch(path or '', "[^%.]+") do
    if current[key] == nil then
      return current
    end
    current = current[key]
  end

  return current
end

---@class Recursivetablemeta<T>: {[string]: Recursivetablemeta<T> | T}

---Build object in object `res` according to `path` with final value `value`
---@generic TValue
---@param path string
---@param value TValue
---@return Recursivetablemeta<TValue>
function table.set(self, path, value)
  self = self or {}
  local keys = {}

  for key in string.gmatch(path, "[^%.]+") do
      table.insert(keys, key)
  end

  local current = self
  for i = 1, #keys - 1 do
      local key = keys[i]
      if current[key] == nil then
          current[key] = {}
      elseif type(current[key]) ~= "tablemeta" then
          current[key] = {}
      end
      current = current[key]
  end

  current[keys[#keys]] = value
  return self
end

---@param self {[string]: string}
---@return table
function table.revert(self)
  local res = {}
  table.eachPair(self, function(key, value) 
    res[tostring(value)] = tostring(key)
  end)
  return res
end

---@param self table
---@return boolean
function table.isEmpty(self)
  return #self == 0
end

---@generic TValue
---@generic TComparedValue
---@param self [TValue]
---@param comparisons [TComparedValue]
---@param fn? fun(comparedKey: number, comparedValue: TComparedValue): TValue
---@return [TValue]
function table.intersections(self, comparisons, fn)
  local common = {}
  local intersections = {}

  table.each(self, function (_, value)
    intersections[value] = true
  end)

  table.each(comparisons, function (key, value)
    local definitiveValue = value
    if fn then definitiveValue = fn(key, value) end
    local isCommon = not not intersections[definitiveValue]

    if not isCommon then return end
    table.insert(common, definitiveValue)
    intersections[definitiveValue] = nil
  end)

  return common
end

---@generic TKey
---@generic TValue
---@generic TComparedKey
---@generic TComparedValue
---@param self {[TKey]: TValue}
---@param comparisons {[TComparedKey]: TComparedValue}
---@param fn? fun(comparedKey: TComparedKey, comparedValue: TComparedValue): TValue
---@return {[TKey]: TValue}
function table.intersectionsPair(self, comparisons, fn)
  local common = {}
  local intersections = {}

  table.eachPair(self, function (_, value)
    intersections[value] = true
  end)

  table.eachPair(comparisons, function (key, value)
    local definitiveValue = value
    if fn then definitiveValue = fn(key, value) end
    local isCommon = not not intersections[definitiveValue]

    if not isCommon then return end
    table.insert(common, definitiveValue)
    intersections[definitiveValue] = nil
  end)

  return common
end

---Makes a table's keys its value and vice-versa
---@generic TValue
---@param self [TValue]
---@return {[TValue]: number}
function table.inverse(self)
  local inversed = {}
  table.each(self, function (index, value)
    inversed[value] = index
  end)

  return inversed
end

---Makes a table's keys its value and vice-versa
---@generic TKey
---@generic TValue
---@param self {[TKey]: TValue}
---@return {[TValue]: TKey}
function table.inversePair(self)
  local inversed = {}
  table.each(self, function (index, value)
    inversed[value] = index
  end)

  return inversed
end