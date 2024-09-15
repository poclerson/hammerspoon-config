function spoon.Utils.getConfig()
  local json = hs.json.read('config.json')

  if not json or type(json) ~= 'table' then
    error('Config not found')
  end

  return json
end