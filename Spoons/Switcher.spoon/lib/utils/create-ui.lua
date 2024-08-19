local switcherUi = require('SwitcherUi')

---Creates necessary `SwitcherUi` instances
---@param ui SwitcherUi.Style?
---@param screen hs.screen
---@return SwitcherUi
function switcher:createUi(ui, screen)
  if ui == nil then
    ui = {}
  end
  if type(ui) ~= 'table' then
    error('ui must be a table')
  end

  return switcherUi.new(self, ui, screen)
end