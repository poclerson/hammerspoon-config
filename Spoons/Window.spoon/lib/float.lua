---@param customEvent Event?
---@param config EventConfig?
---@param window hs.window?
function spoon.Window.float(customEvent, config, window)
  local default = spoon.Window.config.default
  local safeConfig = config or default
  local windowWithFallback = window or hs.application.frontmostApplication():focusedWindow()
  if not windowWithFallback or not windowWithFallback:isStandard() then return end

  local snapshot = windowWithFallback:snapshot()
  print(hs.inspect(snapshot))
  
  local screen = hs.screen.mainScreen()
  local screenFrame = screen:frame()

  local canvas = hs.canvas.new{
    x = 0,
    y = 0,
    w = 1000,
    h = 1000,
  }

  canvas:insertElement{
    type = "image",
    image = snapshot,
  }

  canvas:show()
end