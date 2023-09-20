local sketchy = require('sketchybar')

local bar = {
  name = 'StatusBar',
  black = 0xff181926,
  white = 0xffcad3f5,
  red = 0xffed8796,
  green = 0xffa6da95,
  blue = 0xff8aadf4,
  yellow = 0xffeed49f,
  orange = 0xfff5a97f,
  magenta = 0xffc6a0f6,
  grey = 0xff939ab7,
  transparent = 0x00000000,
  bg1 = 0x803c3e4f,
  bg2 = 0xff494d64,
}

local function togglePopup(name)
  if name == nil or not type(name) == 'string' then
    error('need a valid string value for toggling popup')
  end
  return 'sketchybar -m --set ' .. name .. ' popup.drawing=toggle'
end

local function defaultMenuItems()
  eachPair(sketchy.query('default_menu_items'), function (index, fullName)
    local windowName, windowOwner = fullName:match('(.+),(.+)')
    sketchy.add('alias', fullName, {
      position = 'right',
      click_script = togglePopup(fullName),
      popup = {
        height = 50,
        background = {
          drawing = true,
          color = bar.red,
        }
      }
    })
  end)
end

function bar:init()
  defaultMenuItems()
  sketchy.bar({
    height = 25,
    color = bar.black,
    shadow = true,
    sticky = true,
    padding_right = 10,
    padding_left = 10,
    margin_rigth = 50,
    margin_left = 50,
    blur_radius = 20,
    topmost = true,
    display = 'main',
    position = 'bottom',
    y_offset = 50,
  })
  sketchy.add('item', 'test', {
    position = 'center',
    click_script = togglePopup('test'),
    background = {
      drawing = true,
      color = bar.blue,
    },
    icon = {
      drawing = true,
      string = 'ICON',
      color = bar.black,
      font = {
        style = 'Black',
        size = 16.0
      }
    },
    label = {
      drawing = true,
      string = 'ALLO',
      color = bar.red,
      font = {
        style = 'Black',
        size = 16.0,
      }
    },
    popup = {
      background = {
        drawing = true,
        color = bar.red,
      },
      height = 150,
      topmost = true,
      y_offset = 50,
    }
  })
  sketchy.add('item', 'popup.test', {
    position = 'popup.test',
    label = {
      drawing = true,
      string = 'POPUP',
      color = bar.yellow,
      font = {
        style = 'Black',
        size = 16.0
      }
    }
  })
  -- sketchy.add("item", "prefs", {
  --   position = "center",
  --   icon = {
  --     string = '±',
  --     color = bar.red,
  --     font = {
  --       style = 'Black',
  --       size = 16.0,
  --     },
  --   },
  --   label = {
  --     drawing = true
  --   },
  -- })
  -- sketchy.add('item', )
end

return bar