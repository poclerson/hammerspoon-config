local defaultUi = {
  appWidth = 100,
  padding = 30,
  background = {
    fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
    radius = 20,
    strokeWidth = 0,
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 0 }
  },
  apps = {
    fillColor = { red = 0, green = 0, blue = 0 },
    radius = 1,
    strokeWidth = 0,
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 0 }
  },
  selection = {
    fillColor = { red = 1, green = 1, blue = 1, alpha = 0.5 },
    radius = 10,
    strokeWidth = 0,
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 0 }
  }
}

---@class SwitcherUi
---@field switcher Switcher
---@field background hs.canvas?
---@field apps hs.canvas?
---@field selection hs.canvas?
---@field style SwitcherUi.Style
ui = {
  name = 'SwitcherUi',
  components = {
    background = 'background',
    apps = 'apps',
    selection = 'selection',
  },
  generic = {
    fillFrame = {
      x = 0,
      y = 0,
      w = '100%',
      h = '100%',
    }
  },
}

require('Spoons/SwitcherUi.spoon/lib/init')

---@param switcher Switcher
---@param prefs SwitcherUi.Style? All this `SwitcherUi` instance's default values
---@return SwitcherUi switcherUi `SwitcherUi` instance 
function ui.new(switcher, prefs)
  if switcher == nil then
    error('creating a new switcher ui instance requires a switcher instance')
  end
  if prefs == nil then
    prefs = {}
  end

  local prefsWithFallback = mapDeepPair(defaultUi, function (prefName, pref)
    if type(pref) == 'table' then
      return {[prefName] = mapDeepPair(pref, function (componentName, componentPref)
        return {[componentName] = prefs[prefName] and prefs[prefName][componentName] or componentPref}
      end)}
    end
    return {[prefName] = prefs[prefName] or pref}
  end)

  local self = setmetatable({
    switcher = switcher,
    style = prefsWithFallback,
  }, {
    __index = ui
  })

  local apps = self.switcher.cache:get()

  self.style.height = self.style.padding * 2 + self.style.appWidth
  self.background = hs.canvas.new(self:position(apps))
  self.selection = hs.canvas.new(self:position(apps))
  self.apps = hs.canvas.new(self:position(apps))
  self.background:level(4)
  self.selection:level(5)
  self.apps:level(6)

  self.components = {
    background = self.background,
    selection = self.selection,
    apps = self.apps,
  }
  return self
end

return ui