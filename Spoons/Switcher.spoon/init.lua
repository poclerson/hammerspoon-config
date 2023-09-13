require('lib')

local switcher = {
  name = 'Switcher',
  isOpen = false,
  indexSelected = 1,
}

cache = nil

local ui = hs.loadSpoon('SwitcherUi')
local utils = hs.loadSpoon('Utils')

-- Handles wether or not to redraw everything when the app switcher is opened
local function refresh()
  currentlyOpenApps = utils:getAllOpenApps()
  if cache ~= currentlyOpenApps then
    cache = currentlyOpenApps
    ui:refreshFrames(cache)
    ui:drawBackground(cache)
    ui:drawSelection(switcher.indexSelected)
    ui:drawApps(cache)
  end
end

local function show()
  eachPair(ui.switcher, function(name, canvas) canvas:show() end)
end

local function hide()
  eachPair(ui.switcher, function(name, canvas) canvas:hide() end)
end

local function open()
  switcher.isOpen = true
  switcher.indexSelected = 1

  refresh()
  show()
end

local function close()
  switcher.isOpen = false
  ui:removeAllElements(ui.selection)
  hide()
  cache = utils:getAllOpenApps()
end

local function next()
  switcher.indexSelected = switcher.indexSelected + 1
  if switcher.indexSelected > #utils:getAllOpenApps() then
    switcher.indexSelected = 1
  end
  ui:drawSelection(switcher.indexSelected)
end

local function prev()
  switcher.indexSelected = switcher.indexSelected - 1
  if switcher.indexSelected < 1 then
    switcher.indexSelected = #utils:getAllOpenApps()
  end
  ui:drawSelection(switcher.indexSelected)
end

-- Handle what action to call when keyboard events related to the app switcher are called
local function handleState(event)
  local eventType = event:getType()
  local flags = event:getFlags()
  local keycode = event:getKeyCode()
  local blockDefault = false

  if flags:containExactly{'cmd'} then
    blockDefault = false

    if eventType == hs.eventtap.event.types.keyDown then
      eachPair(switcher.actions, function (name, fn)
        if SwitcherKeyBinds[name] == keycode then
          if name == 'selectNext' then
            fn(switcher:getSelectedApp())
            blockDefault = true
            return
          end
          if switcher.isOpen then
            fn(switcher:getSelectedApp())
            blockDefault = true
          end
          return
        end
        if type(SwitcherKeyBinds[name]) == 'table' then
          eachPair(SwitcherKeyBinds[name], function (fnParameter, fnKeyCode)
            if fnKeyCode == keycode then
              blockDefault = true
              fn(switcher:getSelectedApp(), fnParameter)
            end
          end)
        end
      end)
      return blockDefault
    end
  else
    if switcher.isOpen then
      switcher:openSelected(switcher:getSelectedApp())
      return true
    end
  end
end

function switcher:init()
  switcher.actions = {
    quitSelected = switcher.quitSelected,
    minimizeSelected = switcher.minimizeSelected,
    closeAllWindowsOfSelected = switcher.closeAllWindowsOfSelected,
    selectNext = switcher.selectNext,
    selectPrev = switcher.selectPrev,
    closeSwitcher = switcher.closeSwitcher,
    moveSelectedToScreen = function (application, screenIndex)
      switcher:moveSelectedToScreen(application, screenIndex)
    end,
  }
  cache = utils:getAllOpenApps()
  openHandler = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, handleState)
  openHandler:start()
end

-- Returns the currently selected app
function switcher:getSelectedApp()
  return utils:getAllOpenApps()[switcher.indexSelected]
end

-- Open the application selected by the switcher
function switcher:openSelected(application)
  if switcher.isOpen then
    close()
    if application.instance:isRunning() then
      application.instance:activate()
    else
      hs.application.open(application.name)
    end

    moveToStart(cache, function (app)
      return app.name == application.name
    end)

    return true
  end
end

-- Closes the application selected by the switcher
function switcher:quitSelected(application)
  application.app:kill()
  refreshFrames()
  drawApps()
  next()
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

function switcher:moveSelectedToScreen(application, screenIndex)
  local mainWindow = application.instance:mainWindow()
  mainWindow:moveToScreen(Screens[screenIndex])
  mainWindow:focus()
end

-- Selects the next application
function switcher:selectNext()
  if switcher.isOpen then
    next()
  else
    open()
  end
end

-- Selects the previous application
function switcher:selectPrev()
  prev()
end

-- Closes the switcher
function switcher:closeSwitcher()
  close()
end

return switcher