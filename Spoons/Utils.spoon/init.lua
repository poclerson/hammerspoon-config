local utils = {
  name = 'Utils',
}

function utils.hexToRgb(hex)
  local hex = hex:gsub("#","")
  local rgb = {r =tonumber("0x"..hex:sub(1,2))/255, g = tonumber("0x"..hex:sub(3,4))/255, b = tonumber("0x"..hex:sub(5,6))/255}

  return rgb
end

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