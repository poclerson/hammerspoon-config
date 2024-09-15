getmetatable('').__index = getmetatable('').__index or {}
local string = getmetatable('').__index

---@param self string
---@param str string
---@return boolean
function string:startswith(str)
  return self:find('^' .. str) ~= nil
end

---@param self string
---@return string
function string:firstToUpper()
  return (self:gsub("^%l", string.upper))
end

---Converts a string of kebab case to camel case
---@return string
function string:kebabToCamel()
  local previousChar
  local newStr
  for char in self:gmatch'.' do
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

---@param self string
---@param delimiter string
---@return [string]
function string:split(delimiter)
  local result = {}
  local pattern = "([^" .. delimiter .. "]+)"
  for part in string.gmatch(self, pattern) do
      table.insert(result, part)
  end
  return result
end

return string