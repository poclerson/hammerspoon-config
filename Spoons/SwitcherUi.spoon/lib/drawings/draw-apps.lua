---@param removedApp hs.application?
function ui:drawApps(removedApp)
  local apps = {}
  print(#self.switcher:getCertainOpenApps(), 'certain')
  if self.switcher.appsCaches then
    print(#self.switcher.appsCaches, 'cache')
  end
  hs.fnutils.each(self.switcher:getCertainOpenApps(), function (app)
    if removedApp and removedApp:name() == app.name then
      return
    end
    table.insert(apps, app)
  end)
  hs.fnutils.eachPair(
    apps,
    function(index, app)
      local style = self.style
      local component = self.style.apps

      self.apps:appendElements({
        type = 'image',
        frame = {
          x = style.padding + ((style.appWidth + style.padding) * (index - 1)),
          y = style.padding,
          w = style.appWidth,
          h = style.appWidth,
        },
        flatness = 1,
        image = app.image,
        fillColor = component.fillColor,
        roundedRectRadii = { xRadius = component.radius, yRadius = component.radius},
        strokeWidth = component.strokeWidth,
        strokeColor = component.strokeColor,
      })

      self.apps:appendElements({
        type = 'text',
        text = app.name,
        frame = {
          x = style.padding + ((style.appWidth + style.padding) * (index - 1)),
          y = style.padding + style.appWidth,
          w = style.appWidth,
          h = style.appWidth,
        }
      })
    end
  )
end