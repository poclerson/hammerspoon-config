local utils = hs.loadSpoon('Utils')

local mainScreen = Screens.main

local ui = {
  name = 'SwitcherUi',
  applicationWidth = 100,
  padding = 30,
  color = {
    background = { red = 1, green = 1, blue = 1 },
    application = { red = 0, green = 0, blue = 0 },
    selection = { red = 0.5, green = 0.5, blue = 0.5 }
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

ui.height = ui.padding * 2 + ui.applicationWidth

local function horizontalPadding(apps)
  return ui.padding * (#apps + 1)
end

local function position(apps)
  local applicationsWidth = ui.applicationWidth * #apps
  return {
    w = applicationsWidth + horizontalPadding(apps),
    h = ui.height,
    x = mainScreen:frame().w / 2 - (applicationsWidth + horizontalPadding(apps)) / 2, 
    y = mainScreen:frame().h / 2 - (ui.height) / 2, 
  }
end

function ui:init()
  ui.background = hs.canvas.new(position(utils:getAllOpenApps()))
  ui.selection = hs.canvas.new(position(utils:getAllOpenApps()))
  ui.apps = hs.canvas.new(position(utils:getAllOpenApps()))
  ui.background:level(4)
  ui.selection:level(5)
  ui.apps:level(6)

  ui.switcher = {
    background = ui.background,
    selection = ui.selection,
    apps = ui.apps,
  }
end

-- Draws the background
function ui:drawBackground(apps)
  ui.background:frame(position(apps))
  ui.background:appendElements({
    action = 'fill',
    fillColor = ui.color.background,
    type = 'rectangle',
    frame = ui.generic.fillFrame,
  })
end

-- Draws all app icons
function ui:drawApps(apps)
  each(
    apps, 
    function(index, app)  
      ui.apps:appendElements({
        type = 'image',
        fillColor = ui.color.application,
        action = 'fill',
        image = app.image,
        frame = {
          x = ui.padding + ((ui.applicationWidth + ui.padding) * (index - 1)),
          y = ui.padding,
          w = ui.applicationWidth,
          h = ui.applicationWidth,
        }
      })
    end
  )
end

-- Draws the selection rectangle behind the currently selected app
function ui:drawSelection(index)
  ui.selection:appendElements({
    type = 'rectangle',
    action = 'skip'
  })
  ui.selection:replaceElements({
    type = 'rectangle',
    fillColor = ui.color.selection,
    strokeColor = ui.color.application,
    strokeWidth = 5,
    frame = {
      x =  ui.padding / 2 + ((ui.applicationWidth + ui.padding) * (index - 1)),
      y = ui.padding / 2,
      w = ui.padding + ui.applicationWidth,
      h = ui.padding + ui.applicationWidth,
    }
  })
end

function ui:refreshFrames(apps)
  eachPair(ui.switcher, function (index, canvas)
    canvas:frame(position(apps))
  end)
end

function ui:removeAllElements(canvas)
  eachPair(canvas, function ()
    canvas:removeElement(1)
  end)
end

return ui