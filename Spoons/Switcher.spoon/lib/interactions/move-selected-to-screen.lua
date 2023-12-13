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