function switcher:close()
  self.isOpen = false

  self.ui:removeAllElements(self.ui.selection)

  eachPair(self.ui.components, function (_, canvas)
    canvas:hide()
  end)
end