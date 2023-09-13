require('lib')

local switcher = {
  name = 'Switcher',
}

local switcherUi = hs.loadSpoon('SwitcherUi')

local function refresh(self)
  local cache = self.cache
  local ui = self.ui

  currentlyOpenApps = spoon.Utils:getAllOpenApps()
  if cache ~= currentlyOpenApps then
    cache = currentlyOpenApps
    ui:refreshFrames(cache)
    ui:drawBackground(cache)
    ui:drawSelection(self.indexSelected)
    ui:drawApps(cache)
  end
end

local function show(self)
  eachPair(self.ui.switcher, function(name, canvas) canvas:show() end)
end

local function hide(self)
  eachPair(self.ui.switcher, function(name, canvas) canvas:hide() end)
end

local function open(self)
  self.isOpen = true
  self.indexSelected = 1

  refresh(self)
  show(self)
end

local function close(self)
  local ui = self.ui
  self.isOpen = false
  ui:removeAllElements(ui.selection)
  hide(self)
  self.cache = spoon.Utils:getAllOpenApps()
end

local function next(self)
  self.indexSelected = self.indexSelected + 1
  if self.indexSelected > #spoon.Utils:getAllOpenApps() then
    self.indexSelected = 1
  end
  self.ui:drawSelection(self.indexSelected)
end

local function prev(self)
  self.indexSelected = self.indexSelected - 1
  if self.indexSelected < 1 then
    self.indexSelected = #spoon.Utils:getAllOpenApps()
  end
  self.ui:drawSelection(self.indexSelected)
end

-- Handle what action to call when keyboard events related to the app switcher are called
local function handleState(self, event)
  local eventType = event:getType()
  local flags = event:getFlags()
  local keycode = event:getKeyCode()
  local blockDefault = false

  if flags:containExactly{self.key} then
    blockDefault = false

    if eventType == hs.eventtap.event.types.keyDown then
      eachPair(self.actions, function (name, fn)
        if self.keyBinds[name] == keycode then
          if name == 'selectNext' or self.isOpen then
            fn(self, self:getSelectedApp())
            blockDefault = true
            return
          end
        end
        if type(self.keyBinds[name]) == 'table' then
          eachPair(self.keyBinds[name], function (fnParameter, fnKeyCode)
            if fnKeyCode == keycode then
              if name == 'selectNext' or self.isOpen then
                fn(self, self:getSelectedApp(), fnParameter)
                blockDefault = true
                return
              end
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

    moveToStart(self.cache, function (app)
      return app.name == application.name
    end)

    return true
  end
end

-- Closes the application selected by the switcher
function switcher:quitSelected(application)
  next(self)
  application.instance:kill()
  refresh(self)
  self.ui:drawApps()
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
  print(application, direction)
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
      return screen:toSouth()
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
  return spoon.Utils:getAllOpenApps()[self.indexSelected]
end

--[[
  Creates a new instance of the switcher

  ### Parameters:

  `key`: set the key used to activate the switcher

  `keyBinds`: set all the other key bindings related to different actions
  ~~~ lua
  keyBinds = {
    quitSelected,
    minimizeSelected,
    closeAllWindowsOfSelected,
    selectNext,
    selectPrev,
    closeSwitcher,
    moveSelectedToScreen = {
      [index of global Screens object] = key bind
    },
    moveSelectedToDirection = {
      [cardinal direction] = key bind
    }
  }

  `ui`: `SwitcherUi` object
]]
function switcher.new(key, keyBinds, ui)
  local keyCodes = spoon.Utils.keyCodes

  local defaultKeyBinds = {
    quitSelected = keyCodes.q,
    minimizeSelected = keyCodes.m,
    closeAllWindowsOfSelected = keyCodes.x,
    selectNext = keyCodes.tab,
    selectPrev = keyCodes.ugrave,
    closeSwitcher = keyCodes.esc,
    moveSelectedToScreen = {
      main = keyCodes.num1,
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
    cache = spoon.Utils:getAllOpenApps(),
    ui = switcherUi.new(ui),
    actions = {},
    keyBinds = keyBinds and map(defaultKeyBinds, function (action, keyBind)
      local customKeyBind = keyBinds[action]
      return {[action] = customKeyBind or keyBind}
    end)
  }, {
    __index = switcher
  })
  self.actions = {
    quitSelected = self.quitSelected,
    minimizeSelected = self.minimizeSelected,
    closeAllWindowsOfSelected = self.closeAllWindowsOfSelected,
    selectNext = self.selectNext,
    selectPrev = selectPrev,
    closeSwitcher = self.closeSwitcher,
    moveSelectedToScreen = function (application, screenIndex)
      moveSelectedToScreen(application, screenIndex)
    end,
    moveSelectedToDirection = function (application, direction)
      moveSelectedToDirection(application, direction)
    end,
  }
  self.openHandler = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, function (event)
    handleState(self, event)
  end)
  self.openHandler:start()
  return self
end

return switcher