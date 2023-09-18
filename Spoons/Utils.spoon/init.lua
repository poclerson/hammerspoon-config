local utils = {
  name = 'Utils',
}

---Gets all the open apps under a specific format
---@return {index: {name: string, image: table, instance: table}}
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