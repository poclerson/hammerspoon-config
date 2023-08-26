-- Define global variables
hs.window.animationDuration = 0

local spoons = {
  'Window',
}

for _, spoon in pairs(spoons) do
  hs.loadSpoon(spoon):start()
end