require('lib')
local switcherUi = require('SwitcherUi')

---@class Switcher
---@field indexSelected number
---@field isOpen boolean
---@field key string
---@field keybinds Switcher.Keybinds
---@field type 'system'|'screen'
---@field actions table<Switcher.Actions, function>
---@field screens ScreenChoice
---@field uis table<string, SwitcherUi>
---@field currentScreen hs.screen
---@field appsCaches table<string, Application[]> | Application[]
local switcher = {
  name = 'Switcher',
}

---Creates necessary `SwitcherUi` instances
---@param ui SwitcherUi.Style?
---@param screens ScreenChoice
---@return table<string, SwitcherUi>
function switcher:createUis(ui, screens)
  if ui == nil then
    ui = {}
  end
  if type(ui) ~= 'table' then
    error('ui must be a table')
  end

  ---@param selectedScreens ScreenChoice[]
  ---@return table<string, SwitcherUi>
  local function screenTypes(selectedScreens)
    return hs.fnutils.mapPair(selectedScreens, function (_, screen)
      return {[type(screen) == 'table' and screen:name() or screen] = switcherUi.new(self, ui, screen)}
    end) --[[@as table<string, SwitcherUi>]]
  end

  if type(screens) == 'string' then
    local stringScreenTypes = {
      all = screenTypes(hs.screen.allScreens()),
      main = screenTypes{'main'}
    }
    return stringScreenTypes[screens]
  end
  return screenTypes(screens)
end

---Handles what action to call when keyboard events related to the app switcher are called. Is called on every keyup and keydown
---@param event hs.eventtap.event
function switcher:handleState(event)
  local flags = event:getFlags()

  if not flags:containExactly{self.key} then
    if self.isOpen then
      self:close()
      local selectedApp = self:getSelectedApp()
      if selectedApp then
        self:openSelected(selectedApp)
      end
      return true
    end
    return
  end

  local eventType = event:getType()
  local keycode = event:getKeyCode()

  if eventType == hs.eventtap.event.types.keyDown then
    local selectedApp = self:getSelectedApp()
    local blockDefault = false

    ---@param activatedKeyCode string|table
    ---@param actionName Switcher.Actions
    ---@return boolean
    local function shouldActivateAction(activatedKeyCode, actionName)
      return keycode == activatedKeyCode and (actionName == 'selectNext' or self.isOpen)
    end

    hs.fnutils.eachPair(self.actions, function (name, fn)
      local action = self.keybinds[name]

      -- If the key is directly assigned to the action
      if shouldActivateAction(action, name) then
        fn(selectedApp)
        blockDefault = true
        return
      end

      -- If the action is nested, it has either action parameters or multiple available key binds
      if type(action) == 'table' then
        hs.fnutils.eachPair(action, function (fnParameter, fnKeyCode)

          -- If the action has action parameters
          if shouldActivateAction(fnKeyCode, name) then
            fn(selectedApp, fnParameter)
            blockDefault = true
            return
          end

          -- If the action has multiple key binds
          -- OR
          -- If the action parameter has multiple key binds
          if fnParameter == '__keybinds' or (type(fnKeyCode) == 'table' and fnKeyCode['__keybinds']) then

            -- Choose the table to iterate through depending on the condition
            local keyCodes = fnParameter == '__keybinds' and fnKeyCode or fnKeyCode['__keybinds']
            hs.fnutils.each(keyCodes, function (optionnalKeyCode)
              if shouldActivateAction(optionnalKeyCode, name) then
                fn(selectedApp, fnParameter)
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
end

function switcher:close()
  self.isOpen = false

  hs.fnutils.eachPair(self.uis, function (_, ui)
    ui:removeAllElements(ui.selection)

    hs.fnutils.eachPair(ui.components, function (_, canvas)
      canvas:hide()
    end)
  end)
end

function switcher:next()
  if self.isOpen then
    self.indexSelected = self.indexSelected + 1
    if self.indexSelected > #self:getCertainOpenApps() then
      self.indexSelected = 1
    end
    hs.fnutils.each(self.uis, function (ui)
      ui:drawSelection(self.indexSelected)
    end)
    return
  end

  self.isOpen = true
  self.indexSelected = 1
  self.currentScreen = hs.screen.mainScreen()

  hs.fnutils.each(self.uis, function (ui)
    ui:drawSelection()
    ui:removeAllElements(ui.apps)
    ui:drawApps()
    ui:refreshAllFrames()
    ui:showComponents()
  end)
end

function switcher:prev()
  self.indexSelected = self.indexSelected - 1
  if self.indexSelected < 1 then
    self.indexSelected = #self:getCertainOpenApps()
  end
  hs.fnutils.eachPair(self.uis, function (name, ui)
    ui:drawSelection(self.indexSelected)
  end)
end

---Open the application selected by the switcher
---@param application Application
---@return boolean?
function switcher:openSelected(application)
  if application.instance:isRunning() then
    application.instance:activate()
  else
    hs.application.open(application.name)
  end

  if self.type == 'system' then
    if not self.appsCaches then
      self.appsCaches = self:getCertainOpenApps()
    end
  
    local selectedAppIndex
    hs.fnutils.eachPair(self.appsCaches, function(index, cacheApp) 
      if cacheApp.name == application.name then
        selectedAppIndex = index
      end
    end)
    hs.fnutils.shift(self.appsCaches, selectedAppIndex, 2)
  -- TODO Implement apps caches for screen-specific switchers
  -- else
  --   if not hs.fnutils.some(self.appsCaches, function (cache)
  --     return not cache == nil
  --   end) then
  --     self.appsCaches = hs.fnutils.mapPair(self:getScreens(), function(_, screen)
  --       return {[screen:name()] = self:getCertainOpenApps(screen)}
  --     end)
  --   end
  end
end

---Closes the application selected by the switchers
---@param application Application
function switcher:quitSelected(application)
  hs.fnutils.each(self.uis, function (ui)
    ui:removeAllElements(ui.apps)
    ui:drawApps(application)
    ui:refreshAllFrames(application)
  end)
  if self.indexSelected == #self:getCertainOpenApps() then
    prev(self)
  end
  application.instance:kill()
end

---Minimizes the application selected by the switcher
---@param application Application
function switcher:minimizeSelected(application)
  if application.instance:isHidden() then
    application.instance:unhide()
    return
  end
  application.instance:hide()
end

---Closes all windows of the application selected by the switchers
---@param application Application
function switcher:closeAllWindowsOfSelected(application)
  hs.fnutils.each(application.instance:allWindows(), function (window)
    window:close()
  end)
end

---Moves the main window of the application selected by the switcher to the designated screensaver
---@param application Application
---@param screenIndex 'main'|'string'
function switcher:moveSelectedToScreen(application, screenIndex)
  if #hs.screen.allScreens() <= 1 then
    return
  end
  local mainWindow = application.instance:mainWindow()
  mainWindow:moveToScreen(Screens[screenIndex])
  mainWindow:focus()
end

---Moves the main window of the application selected by the switcher in the designated directional
---@param application Application
---@param direction Direction
function switcher:moveSelectedToDirection(application, direction)
  if #hs.screen.allScreens() <= 1 then
    return
  end
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
  local mainWindow = application.window
  mainWindow:moveToScreen(directions[direction](hs.screen.mainScreen()))
  mainWindow:focus()
end

---@return Application?
function switcher:getSelectedApp() 
  return self:getCertainOpenApps()[self.indexSelected]
end

---@param screen hs.screen?
---@return Application[]|{}?
function switcher:getCertainOpenApps(screen)
  if self.type == 'system' then
    return self.appsCaches or getAllOpenApps()
  end
  return hs.fnutils.filterPair(getAllOpenApps(false), function (_, app)
    if not screen == nil then
      return app.window:screen():name() == screen:name()
    end
    return app.window:screen():name() == self.currentScreen:name()
  end)
end

---@return hs.screen[]
function switcher:getScreens()
  if self.screens == 'main' then
    return {hs.screen.mainScreen()}
  elseif self.screens == 'all' then
    return hs.screen.allScreens()
  else
    if not type(self.screens) == 'table' then
      return {self.screens}
    end
    return self.screens
  end
end

---@param props {name: string, key: string?, keybinds: Switcher.Keybinds?, uiPrefs: SwitcherUi.Style?, screens: ScreenChoice?, type: 'screen'|'system'?}
---@return table switcher Switcher instance
function switcher.new(props)
  local name, key, keybinds, uiPrefs, screens, type =
    props.name,
    props.key or 'cmd',
    props.keybinds or {},
    props.uiPrefs or {},
    props.screens or 'main',
    props.type or 'system'
  if type == 'screen' and screens == 'all' then
    print('switcher can only be of type screen if screens is set to "main" or a single instance of hs.screen')
  end

  ---@type Switcher.Keybinds
  local defaultSwitcher = {
    quitSelected = hs.keycodes.map['q'],
    minimizeSelected = {
      __keybinds = {
        hs.keycodes.map['m'],
        hs.keycodes.map['h'],
      },
    },
    closeAllWindowsOfSelected = hs.keycodes.map['x'],
    selectNext = {
      __keybinds = {
        hs.keycodes.map['tab'],
        hs.keycodes.map['right'],
      },
    },
    selectPrev = {
      __keybinds = {
        hs.keycodes.map['ù'],
        hs.keycodes.map['left'],
      },
    },
    closeSwitcher = hs.keycodes.map['escape'],
    moveSelectedToScreen = {
      main = {
        __keybinds = {
          hs.keycodes.map['1'],
          hs.keycodes.map['4'],
        }
      },
      screen1 = hs.keycodes.map['2'],
      screen2 = hs.keycodes.map['3'],
    },
    moveSelectedToDirection = {
      north = hs.keycodes.map['w'],
      west = hs.keycodes.map['a'],
      south = hs.keycodes.map['s'],
      east = hs.keycodes.map['d'],
    }
  }
  ---@type Switcher
  local self = setmetatable({
    key = key,
    isOpen = false,
    indexSelected = 1,
    actions = {},
    type = type,
    keybinds = keybinds and hs.fnutils.mapPair(defaultSwitcher, function (action, keyBind)
      local customKeyBind = keybinds[action]
      return {[action] = customKeyBind or keyBind}
    end or defaultSwitcher),
    currentScreen = hs.screen.mainScreen(),
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
      self:next()
    end,
    selectPrev = function ()
      self:prev()
    end,
    closeSwitcher = function ()
      self:close()
    end,
    moveSelectedToScreen = function (application, screenIndex)
      self:moveSelectedToScreen(application, screenIndex)
    end,
    moveSelectedToDirection = function (application, direction)
      self:moveSelectedToDirection(application, direction)
    end,
  }
  self.uis = self:createUis(uiPrefs, screens)
  if self.type == 'screen' then
    self.appsCaches = {}
  end
  openHandler = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, function (event)
    return self:handleState(event)
  end)
  openHandler:start()
  hs.fnutils.eachPair(self.uis, function (_, ui)
    ui:drawComponents()
  end)
  return self
end

return switcher