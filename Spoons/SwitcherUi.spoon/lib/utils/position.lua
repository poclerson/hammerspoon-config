---General position the switcher should haven
---@param removedApp hs.application?
---@return table
function ui:position(removedApp)
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