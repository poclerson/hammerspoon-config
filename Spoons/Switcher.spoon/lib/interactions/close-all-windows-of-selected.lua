---Closes all windows of the application selected by the switchers
---@param application Application
function switcher:closeAllWindowsOfSelected(application)
  each(application.instance:allWindows(), function (_, window)
    window:close()
  end)
end