local defaultUi = {
  applicationWidth = 100,
  padding = 30,
  background = {
    fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
    radius = 20,
    strokeWidth = 0,
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 0 }
  },
  applications = {
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

local ui = {
  name = 'SwitcherUi',
  components = {
    background = 'background',
    applications = 'applications',
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

local function position(self, removedApp)
  local appAmount = 0
  hs.fnutils.ieach(getAllOpenApps(), function (app)
    if removedApp and removedApp.name == app.name then
      return
    end
    appAmount = appAmount + 1
  end)
  local horizontalPadding = self.style.padding * (appAmount + 1)
  local applicationsWidth = self.style.applicationWidth * appAmount
  local frame = self:getScreen():frame()

  return {
    w = applicationsWidth + horizontalPadding,
    h = self.style.height,
    x = frame.x + frame.w / 2 - (applicationsWidth + horizontalPadding) / 2,
    y = frame.y + frame.h / 2 - (self.style.height) / 2,
  }
end

function ui:getScreen()
  if self.screen == 'main' then
    return hs.screen.mainScreen()
  end
  return self.screen
end

-- Draws the background
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

-- Draws all app icons
function ui:drawApps(removedApp)
  local applications = {}
  hs.fnutils.each(getAllOpenApps(), function (app)
    if removedApp and removedApp.name == app.name then
      return
    end
    table.insert(applications, app)
  end)
  hs.fnutils.eachPair(
    applications,
    function(index, app)
      local style = self.style
      local component = self.style.applications

      self.apps:appendElements({
        type = 'image',
        frame = {
          x = style.padding + ((style.applicationWidth + style.padding) * (index - 1)),
          y = style.padding,
          w = style.applicationWidth,
          h = style.applicationWidth,
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

-- Draws the selection rectangle behind the currently selected app
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
      x =  style.padding / 2 + ((style.applicationWidth + style.padding) * ((index or 1) - 1)),
      y = style.padding / 2,
      w = style.padding + style.applicationWidth,
      h = style.padding + style.applicationWidth,
    },
    flatness = 1,
    fillColor = component.fillColor,
    roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
    strokeWidth = component.strokeWidth,
    strokeColor = component.strokeColor,
  })
end

function ui:drawSwitcher(index)
  self:drawBackground()
  self:drawSelection(index or 1)
  self:drawApps()
end

function ui:showSwitcher()
  self:eachCanvas(function (name, canvas)
    canvas:show()
  end)
end

function ui:eachCanvas(fn)
  eachPair(self.switcher, function (name, canvas)
    fn(name, canvas)
  end)
end

function ui:refreshAllFrames(removedApp)
  self:eachCanvas(function (name, canvas)
    canvas:frame(position(self, removedApp))
  end)
end

function ui:removeAllElements(canvas)
  eachPair(canvas, function ()
    canvas:removeElement()
  end)
end

---@param prefs table? All this `SwitcherUi` instance's default values
---@param screen table|'main' All instances of `hs.screen` the switcher should appear on.
---@return table switcherUi `SwitcherUi` instance 
function ui.new(prefs, screen)
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
    style = prefsWithFallback,
    screen = screen or Screens['main'],
  }, {
    __index = ui
  })
  self.style.height = self.style.padding * 2 + self.style.applicationWidth
  self.background = hs.canvas.new(position(self, getAllOpenApps()))
  self.selection = hs.canvas.new(position(self, getAllOpenApps()))
  self.apps = hs.canvas.new(position(self, getAllOpenApps()))
  self.background:level(4)
  self.selection:level(5)
  self.apps:level(6)

  self.switcher = {
    background = self.background,
    selection = self.selection,
    apps = self.apps,
  }
  return self
end

return ui