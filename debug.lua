-- Helper function for debugging.
local inspect = require('inspect')
function p(x)
  print('Inspect:')
  print(inspect(x))
end

-- Helper watcher for figuring out keycodes.
flagsWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
  print('Key code: ' .. event:getKeyCode())
end):start()

-- Hot reload for debugging.
hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()
hs.alert.show('Config reloaded')