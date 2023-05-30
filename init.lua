-- A helper function for printing out the contents of a table.
local inspect = require('debug/inspect')
function p(x)
  print(inspect(x))
end


-- The name of my external mouse.
EXTERNAL_MOUSE_NAME = 'Evoluent VerticalMouse C'

externalMouseIsConnected = false
for _, device in pairs(hs.usb.attachedDevices()) do
  -- print(device.productName)
  if device.productName == EXTERNAL_MOUSE_NAME then
    externalMouseIsConnected = true
  end
end


-- Remap [alt + scroll up] -> [scroll to top of page] and
-- [alt + scroll down] -> [scroll to bottom of page].
altScrollMultiple = 50
mouseWatchers = {
  hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    if (
      event:getFlags():containExactly({'alt'}) and
      -- Any time I process or create a scroll event, I set its
      -- eventSourceUserData property to 1 so that I can check for that
      -- property later to make sure I don't process that scroll event
      -- twice. So if eventSourceUserData is 0 (the default value), that
      -- means this is a new scroll event.
      event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == 0
    ) then
      event:setFlags({alt = false})
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
      event:setProperty(
        hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
        event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1) * altScrollMultiple
      )
      event:setProperty(
        hs.eventtap.event.properties.scrollWheelEventFixedPtDeltaAxis1,
        event:getProperty(hs.eventtap.event.properties.scrollWheelEventFixedPtDeltaAxis1) * altScrollMultiple
      )
      event:setProperty(
        hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1,
        event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1) * altScrollMultiple
      )
    end
  end),

}

function startMouseWatchers()
  for _, mouseWatcher in ipairs(mouseWatchers) do
    mouseWatcher:start()
  end
end

function stopMouseWatchers()
  for _, mouseWatcher in ipairs(mouseWatchers) do
    mouseWatcher:stop()
  end
end

if externalMouseIsConnected then
  startMouseWatchers()
end

externalMouseWatcher = hs.usb.watcher.new(function(event)
  if event.productName == EXTERNAL_MOUSE_NAME then
    if event.eventType == 'added' then
      startMouseWatchers()
    elseif event.eventType == 'removed' then
      stopMouseWatchers()
    end
  end
end):start()


-- In Davinci Resolve, remap [cmd + scroll] -> [alt + scroll].
davinciResolveScrollWatcher = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
  if event:getFlags():containExactly({'cmd'}) then
    event:setFlags({alt = true})
    event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
  end
end)

davinciResolveWindowFilter = hs.window.filter.new(function(win)
  -- Here we use a custom function because the DaVinci Resolve window is
  -- not detected for some reason when it is in full screen mode if we
  -- try to use: hs.window.filter.new('DaVinci Resolve')
  return win:application():name() == 'DaVinci Resolve'
end)

davinciResolveWindowFilter:subscribe(hs.window.filter.windowFocused, function()
  davinciResolveScrollWatcher:start()
end)

davinciResolveWindowFilter:subscribe(hs.window.filter.windowUnfocused, function()
  davinciResolveScrollWatcher:stop()
end)


-- In Sublime Text, remap [cmd + scroll] -> [scroll] (this avoids an issue in
-- Sublime Text where it ignores [cmd + scroll] events).
sublimeTextScrollWatcher = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
  if event:getFlags():containExactly({'cmd'}) then
    event:setFlags({cmd = false})
    event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
  end
end)

hs.window.filter.new('Sublime Text'):subscribe(hs.window.filter.windowFocused, function()
  sublimeTextScrollWatcher:start()
end)

hs.window.filter.new('Sublime Text'):subscribe(hs.window.filter.windowUnfocused, function()
  sublimeTextScrollWatcher:stop()
end)


-- -- This PyCharm hotkey makes it so that after pressing the "Complete Current
-- -- Statement" hotkey, we check if the last character of the line we end up on
-- -- is a semicolon, and if so, we press the return key to insert a new line.
-- pyCharmHotkey = hs.hotkey.new('cmd', 'return', function()
--   -- This runs our "Improved Complete Current Statement Macro" PyCharm macro,
--   -- which does the following:
--   -- 1. Action: EditorCompleteStatement (cmd + shift + enter)
--   -- 2. Action: EditorLeftWithSelection (shift + left)
--   -- 3. Action: EditorCopy (ctrl + c)
--   -- 4. Action: EditorRight (right)
--   local prevPasteboardContents = hs.pasteboard.getContents()
--   hs.eventtap.keyStroke({'alt', 'cmd'}, '0', 0)
--
--   -- This delay is needed to make sure the pasteboard contents are updated.
--   -- The value was determined empirically.
--   hs.timer.doAfter(0.06, function()
--     local endOfLineChar = hs.pasteboard.getContents()
--     if endOfLineChar == ';' then
--       -- This delay is needed for some reason to make the return key work.
--       -- The value was determined empirically.
--       hs.timer.doAfter(0.06, function()
--         hs.eventtap.keyStroke({}, 'return', 0)
--       end)
--     end
--     hs.pasteboard.setContents(prevPasteboardContents)
--   end)
-- end, nil, function()
--   -- This is the "repeat" function. It gets called if the hotkey is held down.
--   hs.eventtap.keyStroke({}, 'return', 0)
-- end)
--
-- pyCharmWindowFilter = hs.window.filter.new('PyCharm')
--
-- pyCharmWindowFilter:subscribe(hs.window.filter.windowFocused, function()
--   pyCharmHotkey:enable()
-- end)
--
-- pyCharmWindowFilter:subscribe(hs.window.filter.windowUnfocused, function()
--   -- For some reason this function is sometimes called even when the PyCharm
--   -- window is still focused, so we add this extra check.
--   if not hs.window.focusedWindow() or hs.window.focusedWindow():application():name() ~= 'PyCharm' then
--     pyCharmHotkey:disable()
--   end
-- end)
--
-- if hs.window.focusedWindow() and hs.window.focusedWindow():application():name() == 'PyCharm' then
--   pyCharmHotkey:enable()
-- end


-- The below code automatically reloads this hammer configuration file
-- whenever a file in the ~/.hammerspoon directory is changed, and shows
-- the alert, "Config reloaded", whenever it does. I uncomment this code
-- when debugging.

-- hs.loadSpoon('ReloadConfiguration')
-- spoon.ReloadConfiguration:start()
-- hs.alert.show('Config reloaded')
