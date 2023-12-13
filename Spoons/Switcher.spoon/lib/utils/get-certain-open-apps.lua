---@param screen hs.screen?
---@return Application[]|{}?
function switcher:getCertainOpenApps(screen)
  local allOpenApps = getAllOpenApps()
  if not self.appsCaches then
    return allOpenApps
  end
  if #self.appsCaches == #allOpenApps then
    return self.appsCaches
  end

  -- If we missed some app openings
  if #self.appsCaches < #allOpenApps then
    local openAppsNotInSwitcher = hs.fnutils.toSetPair(
      hs.fnutils.filterPair(allOpenApps, function(_, app)
        return not hs.fnutils.some(self.appsCaches, function(cachedApp)
          return cachedApp.name == app.name
        end)
      end), function (_, app)
        return app.name
      end
    )
    self.appsCaches = hs.fnutils.concat(
      self.appsCaches,
      openAppsNotInSwitcher
    )
    return self.appsCaches
  end

  -- If we missed some app closings
  local unorderedAppsWithoutQuitApps = hs.fnutils.filterPair(self.appsCaches, function(_, cachedApp)
    return hs.fnutils.some(allOpenApps, function (openApp)
      return openApp.name == cachedApp.name
    end)
  end)

  self.appsCaches = hs.fnutils.reorder(unorderedAppsWithoutQuitApps)
  return self.appsCaches
end