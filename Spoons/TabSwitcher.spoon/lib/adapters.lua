local bridgeConfig = (_G.config and _G.config.tabSwitcher and _G.config.tabSwitcher.bridges) or {}
local vscodePort = bridgeConfig.vscode or 38621
local obsidianPort = bridgeConfig.obsidian or 38622

---Escapes a value for use inside an AppleScript string.
---@param value string
---@return string
local function applescriptString(value)
  return (tostring(value):gsub('\\', '\\\\'):gsub('"', '\\"'))
end

---Runs an AppleScript and returns its result.
---@param script string
---@return boolean, any
local function runAppleScript(script)
  local ok, result = hs.osascript.applescript(script)

  return ok, result
end

---Normalizes AppleScript record lists into switcher items.
---@param result any
---@return table[]
local function normalize(result)
  if type(result) ~= 'table' then return {} end

  if result.i ~= nil or result.t ~= nil then
    result = { result }
  end

  local items = {}

  for _, entry in ipairs(result) do
    if type(entry) == 'table' and entry.i ~= nil then
      items[#items + 1] = {
        id = tostring(entry.i),
        title = tostring(entry.t or ''),
        active = entry.a == true,
      }
    end
  end

  return items
end

---Lists Arc tabs through AppleScript, with their space as context.
---@param app hs.application
---@return table[]?, string?
local function chromiumTabs(app)
  local script = string.format([[
tell application "%s"
  tell front window
    set activeId to id of active tab
    set ids to id of every tab
    set titles to title of every tab
    set out to {}
    repeat with sp in spaces
      set end of out to {s:(title of sp), i:(id of every tab of sp)}
    end repeat
  end tell
end tell
return {a:activeId, i:ids, t:titles, spaces:out}
]], applescriptString(app:name()))

  local ok, result = runAppleScript(script)
  if not ok or type(result) ~= 'table' then return nil, 'Arc AppleScript failed' end

  local ids = result.i
  local titles = result.t
  local spaces = result.spaces
  if type(ids) ~= 'table' then ids = ids and { ids } or {} end
  if type(titles) ~= 'table' then titles = titles and { titles } or {} end
  if type(spaces) ~= 'table' then spaces = {} end
  if spaces.s ~= nil then spaces = { spaces } end

  local contexts = {}

  for _, space in ipairs(spaces) do
    local name = tostring(space.s or '')
    local context = name ~= '' and ('[' .. name .. ']') or nil
    local spaceIds = space.i

    if type(spaceIds) ~= 'table' then spaceIds = spaceIds and { spaceIds } or {} end

    for _, id in ipairs(spaceIds) do
      contexts[tostring(id)] = context
    end
  end

  local items = {}

  for index, id in ipairs(ids) do
    local tabId = tostring(id)

    items[#items + 1] = {
      id = tabId,
      title = tostring(titles[index] or ''),
      active = tabId == tostring(result.a),
      context = contexts[tabId],
    }
  end

  return items, nil
end

---Focuses an Arc tab through AppleScript.
---@param app hs.application
---@param id string
---@return boolean, string?
local function chromiumFocus(app, id)
  local script = string.format([[
tell application "%s"
  tell front window
    repeat with i from 1 to (count of tabs)
      if (id of tab i) = "%s" then
        select tab i
        exit repeat
      end if
    end repeat
  end tell
end tell
]], applescriptString(app:name()), applescriptString(id))

  local ok, result = runAppleScript(script)
  if not ok then return false, 'Arc focus failed' end

  return true, nil
end

---Lists Terminal tabs through AppleScript.
---@param app hs.application
---@return table[]?, string?
local function terminalTabs(app)
  local script = [[
tell application "Terminal"
  tell front window
    set out to {}
    repeat with i from 1 to (count of tabs)
      set tabId to tty of tab i
      set tabTitle to custom title of tab i
      if tabTitle = "" then set tabTitle to tabId
      set end of out to {i:tabId, t:tabTitle, a:(selected of tab i)}
    end repeat
  end tell
end tell
return out
]]

  local ok, result = runAppleScript(script)
  if not ok then return nil, 'Terminal AppleScript failed' end

  return normalize(result), nil
end

---Focuses a Terminal tab through AppleScript.
---@param app hs.application
---@param id string
---@return boolean, string?
local function terminalFocus(app, id)
  local script = string.format([[
tell application "Terminal"
  set w to front window
  repeat with i from 1 to (count of tabs of w)
    if (tty of tab i of w) = "%s" then
      set selected tab of w to tab i of w
      exit repeat
    end if
  end repeat
end tell
]], applescriptString(id))

  local ok, result = runAppleScript(script)
  if not ok then return false, 'Terminal focus failed' end

  return true, nil
end

---Reads tabs from a local bridge.
---@param port number
---@param label string
---@return table[]?, string?
local function bridgeTabs(port, label)
  local url = string.format('http://127.0.0.1:%d/tabs', port)
  local ok, status, body = pcall(hs.http.get, url)

  if not ok or status ~= 200 or not body then
    return nil, label .. ' bridge is not running'
  end

  local decodedOk, decoded = pcall(hs.json.decode, body)
  if not decodedOk or type(decoded) ~= 'table' then
    return nil, label .. ' bridge returned invalid data'
  end

  local items = {}

  for _, entry in ipairs(decoded) do
    if type(entry) == 'table' and entry.id ~= nil then
      items[#items + 1] = {
        id = tostring(entry.id),
        title = tostring(entry.title or ''),
        active = entry.active == true,
        context = entry.context and tostring(entry.context) or nil,
        contextWidth = type(entry.contextWidth) == 'number' and entry.contextWidth or nil,
      }
    end
  end

  return items, nil
end

---Focuses a tab through a local bridge.
---@param port number
---@param label string
---@param id string
---@return boolean, string?
local function bridgeFocus(port, label, id)
  local url = string.format('http://127.0.0.1:%d/focus?id=%s', port, hs.http.encodeForQuery(id))
  local ok, status = pcall(hs.http.get, url)

  if not ok or status ~= 200 then
    return false, label .. ' bridge focus failed'
  end

  return true, nil
end

---Lists VS Code tabs through its bridge.
---@param app hs.application
---@return table[]?, string?
local function vscodeTabs(app)
  return bridgeTabs(vscodePort, 'VS Code')
end

---Focuses a VS Code tab through its bridge.
---@param app hs.application
---@param id string
---@return boolean, string?
local function vscodeFocus(app, id)
  return bridgeFocus(vscodePort, 'VS Code', id)
end

---Lists Obsidian tabs through its bridge.
---@param app hs.application
---@return table[]?, string?
local function obsidianTabs(app)
  return bridgeTabs(obsidianPort, 'Obsidian')
end

---Focuses an Obsidian tab through its bridge.
---@param app hs.application
---@param id string
---@return boolean, string?
local function obsidianFocus(app, id)
  return bridgeFocus(obsidianPort, 'Obsidian', id)
end

return {
  ['company.thebrowser.Browser'] = {
    name = 'Arc',
    list = chromiumTabs,
    focus = chromiumFocus,
  },
  ['com.apple.Terminal'] = {
    name = 'Terminal',
    list = terminalTabs,
    focus = terminalFocus,
  },
  ['com.microsoft.VSCode'] = {
    name = 'VS Code',
    list = vscodeTabs,
    focus = vscodeFocus,
  },
  ['md.obsidian'] = {
    name = 'Obsidian',
    list = obsidianTabs,
    focus = obsidianFocus,
  },
}
