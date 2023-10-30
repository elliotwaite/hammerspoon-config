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


-- In Cursor, remap [shift + scroll] -> [scroll] when the cursor is with over
-- the top tabs of the IDE (this is done using the cursors Y offset within the
-- window, so this remapping could also occur if the mouse is over anything
-- else that is also in that range).
--
-- I use this because in VSCode, when you scroll while the mouse is over the
-- top tabs, it will scroll those tabs horizontally, however, I have a habit of
-- holding down shift while scrolling whenver I want to scroll something
-- horizontally, but in VSCode, if you also hold shift while scrolling the
-- tabs, it will also change which tab is currently focused, which isn't what I
-- want, so I use this code to override that behavior by disallowing the shift
-- key to be pressed when scrolling if the vertical position of the mouse within
-- the range where the IDE's top tabs are.
cursorResolveScrollWatcher = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
  if event:getFlags():containExactly({'shift'}) then
    mouseYOffsetFromTopOfWindow = hs.mouse.getAbsolutePosition().y - hs.window.focusedWindow():topLeft().y
    if 35 <= mouseYOffsetFromTopOfWindow and mouseYOffsetFromTopOfWindow <= 70 then
      print('yes', mouseYOffsetFromTopOfWindow)
      event:setFlags({shift = false})
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
    else
      print('no', mouseYOffsetFromTopOfWindow)
    end
  end
end)

cursorWindowFilter = hs.window.filter.new('Cursor')

cursorWindowFilter:subscribe(hs.window.filter.windowFocused, function()
  cursorResolveScrollWatcher:start()
end)

cursorWindowFilter:subscribe(hs.window.filter.windowUnfocused, function()
  cursorResolveScrollWatcher:stop()
end)


-- When the mouse is moved to the bottom right corner of the screen, disable
-- Bluetooth and put the display to sleep. Then when returning from sleep,
-- re-enable Bluetooth.
--
-- This requires installing blueutil: brew install blueutil
--
-- Run `which blueutil` to find out where blueutil was installed, and update
-- the `blueutilPath` variable below if needed.
blueutilPath = '/usr/local/bin/blueutil'
isDisplaySleeping = false

hotCornerWatcher = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(event)
  if (
    event:location().x > hs.screen.mainScreen():frame().w - 1 and
    event:location().y > hs.screen.mainScreen():frame().h - 1
  ) then
    if not isDisplaySleeping then
      hs.execute(blueutilPath .. ' -p 0')
      hs.execute('pmset displaysleepnow')
      isDisplaySleeping = true
    end
  else
    if isDisplaySleeping then
      hs.execute(blueutilPath .. ' -p 1')
      isDisplaySleeping = false
    end
  end
end)

hotCornerWatcher:start()


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
