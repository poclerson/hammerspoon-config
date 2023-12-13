---Minimizes the application selected by the switcher
---@param application Application
function switcher:minimizeSelected(application)
  if application.instance:isHidden() then
    application.instance:unhide()
    return
  end
  application.instance:hide()
end