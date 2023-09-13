local utils = {
  name = 'Utils',
  keyCodes = {
    a = 0,
    s = 1,
    d = 2,
    x = 7,
    q = 12,
    w = 13,
    num1 = 18,
    num2 = 19,
    num3 = 20,
    num4 = 21,
    num5 = 22,
    num6 = 23,
    esc = 53,
    m = 46,
    tab = 48,
    ugrave = 50,
  },
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