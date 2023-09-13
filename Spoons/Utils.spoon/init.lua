local utils = {
  name = 'Utils'
}

--[[
  Returns a table containing all open applications, including only one instance of each
  Format:
  ```
  application = {
    name = app name
    image = app image
    instance = app instance
  }
  ```
]] 
function utils.getAllOpenApps()
  local windows = hs.window.allWindows()

  appsFormatted = {}

  each(windows, function (index, window)
    local app = window:application()
    local appFormatted = {
      name = app:name(),
      image = hs.image.imageFromAppBundle(app:bundleID()),
      instance = app,
    }
    appsFormatted[index] = appFormatted
  end)
  return toSet(appsFormatted)
end

return utils