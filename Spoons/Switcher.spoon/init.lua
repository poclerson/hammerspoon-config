require('lib')
local switcherUi = require('SwitcherUi')
local utils = require('Utils')

local switcher = {
  name = 'Switcher',
}

-- Iterates each canvas of each ui
local function eachUiCanvas(self, fn)
  eachPair(self.uis, function (uiName, ui)
    ui:eachCanvas(function (canvasName, canvas)
      fn(canvasName, canvas, uiName, ui)
    end)
  end)
end

local function show(self)
  eachPair(self.uis, function (name, ui)
    ui:showSwitcher()
    ui:drawSwitcher()
  end)
end

local function hide(self)
  eachUiCanvas(self, function (name, canvas)
    canvas:hide()
  end)
end

local function open(self)
  self.isOpen = true
  self.indexSelected = 1

  eachPair(self.uis, function (index, ui)
    ui:refreshAllFrames()
  end)

  show(self)
end

local function close(self)
  self.isOpen = false

  eachPair(self.uis, function (name, ui)
    ui:removeAllElements(ui.selection)
  end)

  hide(self)
end

local function next(self)
  self.indexSelected = self.indexSelected + 1
  if self.indexSelected > #utils:getAllOpenApps() then
    self.indexSelected = 1
  end
  eachPair(self.uis, function (name, ui)
    ui:drawSelection(self.indexSelected)
  end)
end

local function prev(self)
  self.indexSelected = self.indexSelected - 1
  if self.indexSelected < 1 then
    self.indexSelected = #utils:getAllOpenApps()
  end
  eachPair(self.uis, function (name, ui)
    ui:drawSelection(self.indexSelected)
  end)
end

--[[
  Creates all the necessary `SwitcherUi` instances from the screens provided
  in `swithcher.new`
]]
local function createUis(self, ui, screens)
  if ui == nil then
    ui = {}
  end
  if type(ui) ~= 'table' then
    error('ui must be a table')
  end
  local function screenTypes(selectedScreens)
    return map(selectedScreens, function (index, screen)
      return {[screen.name and screen:name() or screen] = switcherUi.new(ui, screen)}
    end)
  end
  if type(screens) == 'string' then
    local stringScreenTypes = {
      all = screenTypes(hs.screen.allScreens()),
      main = screenTypes{'main'}
    }
    return stringScreenTypes[screens]
  end
  if type(screens) == 'table' then
    return screenTypes(screens)
  end
end

--[[
  Handle what action to call when keyboard events related to the app switcher are called

  Is called on every keyup and keydown
]]
local function handleState(self, event)
  local eventType = event:getType()
  local flags = event:getFlags()
  local keycode = event:getKeyCode()
  local blockDefault = false

  local function shouldActivateAction(activatedKeyCode, actionName)
    return keycode == activatedKeyCode and (actionName == 'selectNext' or self.isOpen)
  end

  if flags:containExactly{self.key} then
    blockDefault = false

    if eventType == hs.eventtap.event.types.keyDown then
      eachPair(self.actions, function (name, fn)
        -- If the key is directly assigned to the action
        if shouldActivateAction(self.keyBinds[name], name) then
          fn(self:getSelectedApp())
          blockDefault = true
          return
        end

        -- If the action is nested, it has either action parameters or multiple available key binds
        if type(self.keyBinds[name]) == 'table' then
          eachPair(self.keyBinds[name], function (fnParameter, fnKeyCode)

            -- If the action has action parameters
            if shouldActivateAction(fnKeyCode, name) then
              fn(self:getSelectedApp(), fnParameter)
              blockDefault = true
              return
            end

            -- If the action has multiple key binds
            -- OR
            -- If the action parameter has multiple key binds
            if fnParameter == '__keyBinds' or (type(fnKeyCode) == 'table' and fnKeyCode['__keyBinds']) then

              -- Choose the table to iterate through depending on the condition
              local keyCodes = fnParameter == '__keyBinds' and fnKeyCode or fnKeyCode['__keyBinds']
              each(keyCodes, function (index, optionnalKeyCode)
                if shouldActivateAction(optionnalKeyCode, name) then
                  fn(self:getSelectedApp(), fnParameter)
                  blockDefault = true
                  return
                end
              end)
              return
            end
          end)
        end
      end)
      return blockDefault
    end
  else
    if self.isOpen then
      self:openSelected(self:getSelectedApp())
      return true
    end
  end
end

-- Open the application selected by the switcher
function switcher:openSelected(application)
  if self.isOpen then
    close(self)
    if application.instance:isRunning() then
      application.instance:activate()
    else
      hs.application.open(application.name)
    end

    moveToStart(utils:getAllOpenApps(), function (app)
      return app.name == application.name
    end)

    return true
  end
end

-- Closes the application selected by the switcher
function switcher:quitSelected(application)
  eachPair(self.uis, function (index, ui)
    ui:refreshFrame(ui.apps, application)
    ui:refreshFrame(ui.selection, application)
    ui:removeAllElements(ui.background)
    ui:removeAllElements(ui.apps)
    ui:drawBackground(application)
    ui:drawApps(application)
  end)
  next(self)
  application.instance:kill()
end

-- Minimizes the application selected by the switcher
function switcher:minimizeSelected(application)
  application.instance:hide()
end

-- Closes all windows of the application selected by the switcher
function switcher:closeAllWindowsOfSelected(application)
  each(application.instance:allWindows(), function (index, window)
    window:close()
  end)
end

-- Moves the main window of the application selected by the switcher to the designated screen
function switcher:moveSelectedToScreen(application, screenIndex)
  local mainWindow = application.instance:mainWindow()
  mainWindow:moveToScreen(Screens[screenIndex])
  mainWindow:focus()
end

-- Moves the main window of the application selected by the switcher in the designated direction
function switcher:moveSelectedToDirection(application, direction)
  local directions = {
    north = function (screen)
      local frame = screen:fullFrame()
      local side = hs.geometry.rect(frame.x + frame.w / 2, frame.y, 1, 1)
      return screen:toNorth(side)
    end,
    west = function (screen)
      local frame = screen:fullFrame()
      local side = hs.geometry.rect(frame.x, frame.y + frame.h / 2, 1, 1)
      return screen:toWest(side)
    end,
    south = function (screen)
      local frame = screen:fullFrame()
      local side = hs.geometry.rect(frame.x + frame.w / 2, frame.y, 1, 1)
      return screen:toSouth(side)
    end,
    east = function (screen)
      local frame = screen:fullFrame()
      local side = hs.geometry.rect(frame.x + frame.w, frame.y + frame.h / 2, 1, 1)
      return screen:toEast(side)
    end,
  }
  -- printTable(directions[direction])
  local mainWindow = application.instance:mainWindow()
  mainWindow:moveToScreen(directions[direction](hs.screen.mainScreen()))
  mainWindow:focus()
end

-- Selects the next application
function switcher:selectNext()
  if self.isOpen then
    next(self)
  else
    open(self)
  end
end

-- Selects the previous application
function switcher:selectPrev()
  prev(self)
end

-- Closes the switcher
function switcher:closeSwitcher()
  close(self)
end

function switcher:getSelectedApp()
  return utils:getAllOpenApps()[self.indexSelected]
end

---@param key string? Key necessary for all commands, like `cmd` or `alt`
---@param keyBinds table? Keys of all the actions available.
---@param uiPrefs table? `SwitcherUi` object
---@param screens table|'main'|'all'? Table containing all `hs.screen` objects the switcher should appear on. 
---@return table switcher `Switcher instance`
function switcher.new(key, keyBinds, uiPrefs, screens)
  local keyCodes = utils.keyCodes

  local defaultKeyBinds = {
    quitSelected = keyCodes.q,
    minimizeSelected = {
      __keyBinds = {
        keyCodes.m,
        keyCodes.h,
      },
    },
    closeAllWindowsOfSelected = keyCodes.x,
    selectNext = {
      __keyBinds = {
        keyCodes.tab,
        keyCodes.rightarrow,
      },
    },
    selectPrev = {
      __keyBinds = {
        keyCodes.ugrave,
        keyCodes.leftarrow,
      },
    },
    closeSwitcher = keyCodes.esc,
    moveSelectedToScreen = {
      main = {
        __keyBinds = {
          keyCodes.num1,
          keyCodes.num4,
        }
      },
      screen1 = keyCodes.num2,
      screen2 = keyCodes.num3,
    },
    moveSelectedToDirection = {
      north = keyCodes.w,
      west = keyCodes.a,
      south = keyCodes.s,
      east = keyCodes.d,
    }
  }

  local self = setmetatable({
    key = key and key or 'alt',
    isOpen = false,
    indexSelected = 1,
    actions = {},
    keyBinds = keyBinds and map(defaultKeyBinds, function (action, keyBind)
      local customKeyBind = keyBinds[action]
      return {[action] = customKeyBind or keyBind}
    end or defaultKeyBinds)
  }, {
    __index = switcher
  })
  self.actions = {
    quitSelected = function (application)
      self:quitSelected(application)
    end,
    minimizeSelected = function (application)
      self:minimizeSelected(application)
    end,
    closeAllWindowsOfSelected = function (application)
      self:closeAllWindowsOfSelected(application)
    end,
    selectNext = function ()
      self:selectNext()
    end,
    selectPrev = function ()
      self:selectPrev()
    end,
    closeSwitcher = function ()
      self:closeSwitcher()
    end,
    moveSelectedToScreen = function (application, screenIndex)
      self:moveSelectedToScreen(application, screenIndex)
    end,
    moveSelectedToDirection = function (application, direction)
      self:moveSelectedToDirection(application, direction)
    end,
  }
  self.uis = createUis(self, uiPrefs, screens)
  self.openHandler = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, function (event)
    return handleState(self, event)
  end)
  self.openHandler:start()
  eachPair(self.uis, function (index, ui)
    ui:drawSwitcher()
  end)
  return self
end

return switcher