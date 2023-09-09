local ui = {
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
  }
}

mainScreen = hs.screen.find('U28E590'):fullFrame()
screenWidth = mainScreen.w
screenHeight = mainScreen.h

ui.height = ui.padding * 2 + ui.applicationWidth

function ui:verticalPadding()
  return self.padding * 2
end

function ui:horizontalPadding()
  return self.padding * (#spoon.Switcher:getAllOpensApps() + 1)
end

function ui:position()
  local applicationAmount = #spoon.Switcher:getAllOpensApps()
  local applicationsWidth = ui.applicationWidth * applicationAmount
  return {
    w = applicationsWidth + ui:horizontalPadding(),
    h = ui.height,
    x = screenWidth / 2 - (applicationsWidth + ui:horizontalPadding()) / 2, 
    y = screenHeight / 2 - (ui.height) / 2, 
  }
end

return ui