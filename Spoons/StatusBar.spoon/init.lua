local bar = {
  name = 'StatusBar',
}

function bar:init()
  -- printTable(hs.fnutils.imap(getAllOpenApps(), function (app)
  --   return {[app.name] = app.instance:findMenuItem('(.*?)', true)}
  -- end))
end

return bar