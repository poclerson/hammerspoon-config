---@param window hs.window?
function spoon.Window.windowFocused(window)
  spoon.Utils.actionDispatcher(nil, Config.window.windowFocused)
end