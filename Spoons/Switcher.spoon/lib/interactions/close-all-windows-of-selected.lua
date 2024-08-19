---Closes all windows of the application selected by the switchers
---@param application Application
function switcher:closeAllWindowsOfSelected(application)
  hs.fnutils.each(application.instance:allWindows(), function (window)
    window:close()
  end)
end