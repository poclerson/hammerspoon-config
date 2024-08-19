local filenames = {
  'interactions/close-all-windows-of-selected',
  'interactions/close',
  'interactions/minimize-selected',
  'interactions/move-selected-to-direction',
  'interactions/move-selected-to-screen',
  'interactions/next',
  'interactions/open-selected',
  'interactions/prev',
  'interactions/quit-selected',
  'utils/get-selected-app',
  'utils/handle-state'
}

return createRequires(filenames, 'Spoons/Switcher.spoon/lib/')