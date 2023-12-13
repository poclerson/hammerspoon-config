---Handles what action to call when keyboard events related to the app switcher are called. Is called on every keyup and keydown
---@param event hs.eventtap.event
function switcher:handleState(event)
  local flags = event:getFlags()

  if not flags:containExactly{self.key} then
    if self.isOpen then
      self:close()
      local selectedApp = self:getSelectedApp()
      if selectedApp then
        self:openSelected(selectedApp)
      end
      return true
    end
    return
  end

  local eventType = event:getType()
  local keycode = event:getKeyCode()

  if eventType == hs.eventtap.event.types.keyDown then
    local selectedApp = self:getSelectedApp()
    local blockDefault = false

    ---@param activatedKeyCode string|table
    ---@param actionName Switcher.Actions
    ---@return boolean
    local function shouldActivateAction(activatedKeyCode, actionName)
      return keycode == activatedKeyCode and (actionName == 'selectNext' or self.isOpen)
    end

    hs.fnutils.eachPair(self.actions, function (name, fn)
      local action = self.keybinds[name]

      -- If the key is directly assigned to the action
      if shouldActivateAction(action, name) then
        fn(selectedApp)
        blockDefault = true
        return
      end

      -- If the action is nested, it has either action parameters or multiple available key binds
      if type(action) == 'table' then
        hs.fnutils.eachPair(action, function (fnParameter, fnKeyCode)

          -- If the action has action parameters
          if shouldActivateAction(fnKeyCode, name) then
            fn(selectedApp, fnParameter)
            blockDefault = true
            return
          end

          -- If the action has multiple key binds
          -- OR
          -- If the action parameter has multiple key binds
          if fnParameter == '__keybinds' or (type(fnKeyCode) == 'table' and fnKeyCode['__keybinds']) then

            -- Choose the table to iterate through depending on the condition
            local keyCodes = fnParameter == '__keybinds' and fnKeyCode or fnKeyCode['__keybinds']
            hs.fnutils.each(keyCodes, function (optionnalKeyCode)
              if shouldActivateAction(optionnalKeyCode, name) then
                fn(selectedApp, fnParameter)
                blockDefault = true
                return
              end
            end)
            return
          end
        end)
      end
    end)
    return blockDefault
  end
end