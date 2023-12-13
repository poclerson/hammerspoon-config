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