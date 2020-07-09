-- For printing out the contents of a table.
local inspect = require('debug/inspect')
function p(x)
  print(inspect(x))
end

-- For figuring out the key codes of modifier keys.
flagsWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
  print('Key code: ' .. event:getKeyCode())
end):start()

-- For hot reloading.
hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()
hs.alert.show('Config reloaded')