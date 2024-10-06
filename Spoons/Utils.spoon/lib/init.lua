local filenames = {
  '/watch-config-events',
  '/handle-action',
  '/is-action',
  '/is-keyboard-action',
  '/is-keyboard-event',
  '/trigger-action',
}

return spoon.Utils.createRequires(filenames, 'Spoons/Utils.spoon/lib')