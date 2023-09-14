local utils = hs.loadSpoon('Utils')

local defaultUi = {
  applicationWidth = 100,
  padding = 30,
  color = {
    background = { red = 1, green = 1, blue = 1 },
    application = { red = 0, green = 0, blue = 0 },
    selection = { red = 0.5, green = 0.5, blue = 0.5 }
  },
}

local ui = {
  name = 'SwitcherUi',
  generic = {
    fillFrame = {
      x = 0,
      y = 0,
      w = '100%',
      h = '100%',
    }
  },
}

local function horizontalPadding(self, apps)
  return self.padding * (#apps + 1)
end

local function position(self, apps)
  local applicationsWidth = self.applicationWidth * #apps
  local frame = self:getScreen():frame()
  return {
    w = applicationsWidth + horizontalPadding(self, apps),
    h = self.height,
    x = frame.x + frame.w / 2 - (applicationsWidth + horizontalPadding(self, apps)) / 2, 
    y = frame.y + frame.h / 2 - (self.height) / 2, 
  }
end

function ui:getScreen()
  if self.screen == 'main' then
    return hs.screen.mainScreen()
  end
  return self.screen
end

-- Draws the background
function ui:drawBackground(apps)
  self.background:frame(position(self, apps))
  self.background:appendElements({
    action = 'fill',
    fillColor = self.color.background,
    type = 'rectangle',
    frame = self.generic.fillFrame,
  })
end

-- Draws all app icons
function ui:drawApps(apps)
  each(
    apps, 
    function(index, app)  
      self.apps:appendElements({
        type = 'image',
        fillColor = self.color.application,
        action = 'fill',
        image = app.image,
        frame = {
          x = self.padding + ((self.applicationWidth + self.padding) * (index - 1)),
          y = self.padding,
          w = self.applicationWidth,
          h = self.applicationWidth,
        }
      })
    end
  )
end

-- Draws the selection rectangle behind the currently selected app
function ui:drawSelection(index)
  self.selection:appendElements({
    type = 'rectangle',
    action = 'skip'
  })
  self.selection:replaceElements({
    type = 'rectangle',
    fillColor = self.color.selection,
    strokeColor = self.color.application,
    strokeWidth = 5,
    frame = {
      x =  self.padding / 2 + ((self.applicationWidth + self.padding) * (index - 1)),
      y = self.padding / 2,
      w = self.padding + self.applicationWidth,
      h = self.padding + self.applicationWidth,
    }
  })
end

function ui:eachCanvas(fn)
  eachPair(self.switcher, function (name, component)
    fn(component)
  end)
end

function ui:refreshFrames(apps)
  eachPair(self.switcher, function (index, canvas)
    canvas:frame(position(self, apps))
  end)
end

function ui:removeAllElements(canvas)
  eachPair(canvas, function ()
    canvas:removeElement(1)
  end)
end

---@param prefs table All this `SwitcherUi` instance's default values
---@param screen table|'main' All instances of `hs.screen` the switcher should appear on.
---@return table switcherUi `SwitcherUi` instance 
function ui.new(prefs, screen)
  if prefs == nil then
    prefs = {}
  end
  local self = setmetatable({
    color = prefs.color and prefs.color or defaultUi.color,
    applicationWidth = prefs.applicationWidth and prefs.applicationWidth or defaultUi.applicationWidth,
    padding = prefs.padding and prefs.padding or defaultUi.padding,
    screen = screen or Screens['main']
  }, {
    __index = ui
  })
  self.height = self.padding * 2 + self.applicationWidth
  self.background = hs.canvas.new(position(self, utils:getAllOpenApps()))
  self.selection = hs.canvas.new(position(self, utils:getAllOpenApps()))
  self.apps = hs.canvas.new(position(self, utils:getAllOpenApps()))
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