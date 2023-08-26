-- Define global variables
hs.window.animationDuration = 0

local spoons = {
  'Window',
  'Touch',
}

for _, spoon in pairs(spoons) do
  hs.loadSpoon(spoon):start()
end