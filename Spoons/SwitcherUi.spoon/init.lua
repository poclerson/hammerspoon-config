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
---@field screen table|'main'
---@field background hs.canvas?
---@field apps hs.canvas?
---@field selection hs.canvas?
---@field style SwitcherUi.Style
local ui = {
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

---General position the switcher should haven
---@param self SwitcherUi
---@param removedApp hs.application?
---@return table
local function position(self, removedApp)
  local appAmount = 0
  hs.fnutils.ieach(self.switcher:getCertainOpenApps(), function (app)
    if removedApp and removedApp.name == app.name then
      return
    end
    appAmount = appAmount + 1
  end)
  local horizontalPadding = self.style.padding * (appAmount + 1)
  local appsWidth = self.style.appWidth * appAmount
  local frame = self:getScreen():frame()

  return {
    w = appsWidth + horizontalPadding,
    h = self.style.height,
    x = frame.x + frame.w / 2 - (appsWidth + horizontalPadding) / 2,
    y = frame.y + frame.h / 2 - (self.style.height) / 2,
  }
end

---Gets the correct screen
---@return hs.screen
function ui:getScreen()
  if self.screen == 'main' then
    return hs.screen.mainScreen()
  end
  return self.screen --[[@as hs.screen]]
end

---@param removedApp hs.application?
function ui:drawBackground(removedApp)
  local component = self.style.background

  self.background:frame(position(self, removedApp))
  self.background:appendElements({
    type = 'rectangle',
    frame = self.generic.fillFrame,
    flatness = 1,
    fillColor = component.fillColor,
    roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
    strokeWidth = component.strokeWidth,
    strokeColor = component.strokeColor,
  })
end

---@param removedApp hs.application?
function ui:drawApps(removedApp)
  local apps = {}
  hs.fnutils.each(self.switcher:getCertainOpenApps(), function (app)
    if removedApp and removedApp.name == app.name then
      return
    end
    table.insert(apps, app)
  end)
  hs.fnutils.eachPair(
    apps,
    function(index, app)
      local style = self.style
      local component = self.style.apps

      self.apps:appendElements({
        type = 'image',
        frame = {
          x = style.padding + ((style.appWidth + style.padding) * (index - 1)),
          y = style.padding,
          w = style.appWidth,
          h = style.appWidth,
        },
        flatness = 1,
        image = app.image,
        fillColor = component.fillColor,
        roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
        strokeWidth = component.strokeWidth,
        strokeColor = component.strokeColor,
      })
    end
  )
end

---@param index number
function ui:drawSelection(index)
  local style = self.style
  local component = self.style.selection

  self.selection:appendElements({
    type = 'rectangle',
    action = 'skip'
  })
  self.selection:replaceElements({
    type = 'rectangle',
    frame = {
      x =  style.padding / 2 + ((style.appWidth + style.padding) * ((index or 1) - 1)),
      y = style.padding / 2,
      w = style.padding + style.appWidth,
      h = style.padding + style.appWidth,
    },
    flatness = 1,
    fillColor = component.fillColor,
    roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
    strokeWidth = component.strokeWidth,
    strokeColor = component.strokeColor,
  })
end

---@param index number?
function ui:drawComponents(index)
  self:drawBackground()
  self:drawSelection(index or 1)
  self:drawApps()
end

function ui:showComponents()
  self:eachCanvas(function (name, canvas)
    canvas:show()
  end)
end

---@param fn function
function ui:eachCanvas(fn)
  hs.fnutils.eachPair(self.components, function (name, canvas)
    fn(name, canvas)
  end)
end

---@param removedApp hs.application
function ui:refreshAllFrames(removedApp)
  self:eachCanvas(function (_, canvas)
    canvas:frame(position(self, removedApp))
  end)
end

---@param canvas hs.canvas
function ui:removeAllElements(canvas)
  hs.fnutils.each(canvas, function ()
    canvas:removeElement()
  end)
end

---@param switcher Switcher
---@param prefs SwitcherUi.Style? All this `SwitcherUi` instance's default values
---@param screen hs.screen|'main' All instances of `hs.screen` the switcher should appear on.
---@return SwitcherUi switcherUi `SwitcherUi` instance 
function ui.new(switcher, prefs, screen)
  if switcher == nil then
    error('creating a new switcher ui instance requires a switcher instance')
  end
  if prefs == nil then
    prefs = {}
  end

  local prefsWithFallback = hs.fnutils.mapPair(defaultUi, function (prefName, pref)
    if type(pref) == 'table' then
      return {[prefName] = hs.fnutils.mapPair(pref, function (componentName, componentPref)
        return {[componentName] = prefs[prefName] and prefs[prefName][componentName] or componentPref}
      end)}
    end
    return {[prefName] = prefs[prefName] or pref}
  end)

  local self = setmetatable({
    switcher = switcher,
    style = prefsWithFallback,
    screen = screen or Screens['main'],
  }, {
    __index = ui
  })
  self.style.height = self.style.padding * 2 + self.style.appWidth
  self.background = hs.canvas.new(position(self, self.switcher:getCertainOpenApps()))
  self.selection = hs.canvas.new(position(self, self.switcher:getCertainOpenApps()))
  self.apps = hs.canvas.new(position(self, self.switcher:getCertainOpenApps()))
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