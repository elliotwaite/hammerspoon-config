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

-- For printing all of the properties of an event.
function print_event_properties(event)
  print('---start---')
  for key, val in pairs(hs.eventtap.event.properties) do
    if type(key) == 'string' then
      print(key, event:getProperty(hs.eventtap.event.properties[key]))
    end
  end
  print('---end---')
end