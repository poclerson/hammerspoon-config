require('lib')

---@class Switcher
---@field indexSelected number
---@field isOpen boolean
---@field key string
---@field keybinds Switcher.Keybinds
---@field type 'system'|'screen'
---@field actions table<Switcher.Actions, function>
---@field screens ScreenChoice
---@field ui SwitcherUi
---@field currentScreen hs.screen
---@field cache SwitcherCache
switcher = {
  name = 'Switcher',
}

require('Spoons/Switcher.spoon/lib/init')
hs.loadSpoon('SwitcherCache')
hs.loadSpoon('SwitcherUi')

---@param props {name: string, key: string?, keybinds: Switcher.Keybinds?, uiPrefs: SwitcherUi.Style?}
---@return Switcher switcher Switcher instance
function switcher.new(props)
  local _, key, keybinds, uiPrefs =
    props.name,
    props.key or 'cmd',
    props.keybinds or {},
    props.uiPrefs or {}

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
  local self = setmetatable({
    key = key,
    isOpen = false,
    indexSelected = 1,
    actions = {},
    keybinds = keybinds and mapPair(defaultSwitcher, function (action, keyBind)
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

  self.cache = cache.new(self)
  self.ui = ui.new(self, uiPrefs)

  openHandler = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, function (event)
    return self:handleState(event)
  end)

  openHandler:start()
  self.ui:drawComponents()

  return self
end

return switcher