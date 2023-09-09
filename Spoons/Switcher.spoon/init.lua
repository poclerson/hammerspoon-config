require('utils')

local spoon = {
  name = 'Switcher',
  isOpen = false,
  indexSelected = 1,
  applicationsCache = nil
}

local ui = hs.loadSpoon('SwitcherUi')

local function removeAllElements(canvas)
  eachPair(canvas, function ()
    canvas:removeElement(1)
  end)
end

local function refreshFrames()
  eachPair(canvas, function (index, canva)
    canva:frame(ui:position())
  end)
end

local function drawBackground()
  canvas.background:frame(ui:position())
  canvas.background:appendElements({
    action = 'fill',
    fillColor = ui.color.background,
    type = 'rectangle',
    frame = ui.generic.fillFrame,
  })
end

local function drawApps()
  each(
    spoon:getAllOpensApps(), 
    function(index, app)  
      canvas.apps:appendElements({
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

local function drawSelection()
  canvas.selection:appendElements({
    type = 'rectangle',
    action = 'skip'
  })
  canvas.selection:replaceElements({
    type = 'rectangle',
    fillColor = ui.color.selection,
    strokeColor = ui.color.application,
    strokeWidth = 5,
    frame = {
      x =  ui.padding / 2 + ((ui.applicationWidth + ui.padding) * (spoon.indexSelected - 1)),
      y = ui.padding / 2,
      w = ui.padding + ui.applicationWidth,
      h = ui.padding + ui.applicationWidth,
    }
  })
end

local function handleOpening(event)
  local type = event:getType()
  local flags = event:getFlags()
  local keycode = event:getKeyCode()

  if flags:containExactly{'alt'} then
    if type == hs.eventtap.event.types.keyDown then
      eachPair(keyCodes, function (key, action)
        if action.code == keycode then
          action.onKeyUp()
          if action.changeLayout then
            refreshFrames()
            drawApps()
            spoon:next()
          end
        end
      end)
    end
  else
    if spoon.isOpen then
      spoon:close()
      hs.application.open(spoon:getAllOpensApps()[spoon.indexSelected].name)
      return true
    end
  end
end

function spoon:start()
  keyCodes = {
    esc = {
      code = 53,
      onKeyUp = spoon.close
    },
    tab = {
      code = 48,
      onKeyUp = function ()
        if spoon.isOpen then
          spoon:next()
        else
          spoon:open()
        end
      end
    },
    ugrave = {
      code = 50,
      onKeyUp = spoon.prev
    },
    q = {
      code = 12,
      onKeyUp = function ()
        spoon:getSelectedApp().app:kill()
      end,
      changeLayout = true,
    },
    m = {
      code = 46,
      onKeyUp = function ()
        spoon:getSelectedApp().app:hide()
      end
    },
    w = {
      code = 13,
      onKeyUp = function ()
        each(spoon:getSelectedApp().app:allWindows(), function (index, window)
          window:close()
        end)
      end
    },
  }

  canvas = {
    background = hs.canvas.new(ui:position()),
    selection = hs.canvas.new(ui:position()),
    apps = hs.canvas.new(ui:position()),
  }

  canvas.background:level(4)
  canvas.selection:level(5)
  canvas.apps:level(6)

  openHandler = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.flagsChanged,
  }, handleOpening)
  openHandler:start()
end

function spoon:show()
  eachPair(canvas, function(name, canvas) canvas:show()  end)
end

function spoon:hide()
  eachPair(canvas, function(name, canvas) canvas:hide()  end)
end

function spoon:open()
  spoon.isOpen = true
  spoon.indexSelected = 1

  refreshFrames()
  drawBackground()
  drawSelection()
  drawApps()
  spoon:show()
end

function spoon:close()
  spoon.isOpen = false
  removeAllElements(canvas.selection)
  spoon:hide()
  spoon.applicationsCache = spoon:getAllOpensApps()
end

function spoon:next()
  spoon.indexSelected = spoon.indexSelected + 1
  if spoon.indexSelected > #spoon:getAllOpensApps() then
    spoon.indexSelected = 1
  end
  drawSelection()
end

function spoon:prev()
  spoon.indexSelected = spoon.indexSelected - 1
  if spoon.indexSelected < 1 then
    spoon.indexSelected = #spoon:getAllOpensApps()
  end
  drawSelection()
end

-- Returns a table containing all open applications, including only one instance of each
function spoon:getAllOpensApps()
  local windows = hs.window.allWindows()

  appsFormatted = {}

  each(windows, function (index, window)
    local app = window:application()
    local appFormatted = {
      name = app:name(),
      image = hs.image.imageFromAppBundle(app:bundleID()),
      app = app,
    }
    appsFormatted[index] = appFormatted
  end)
  return toSet(appsFormatted)
end

function spoon:getSelectedApp()
  return spoon:getAllOpensApps()[spoon.indexSelected]
end

return spoon