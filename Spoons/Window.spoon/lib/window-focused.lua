---@param window hs.window?
function spoon.Window.windowFocused(window)
  spoon.Utils.actionDispatcher({ name = 'windowFocused' }, Config.window.windowFocused)
end