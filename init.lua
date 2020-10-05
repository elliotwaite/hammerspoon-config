-- A helper function for printing out the contents of a table.
local inspect = require('debug/inspect')
function p(x)
  print(inspect(x))
end

-- The name of my external keyboard. This is used below to make certain
-- hotkeys only apply when my external keyboard is not connected.
EXTERNAL_KEYBOARD_NAME = 'Advantage2 Keyboard'

-- The name of my external mouse. This is used below to swap the middle
-- and right mouse button events when my external mouse is connected.
EXTERNAL_MOUSE_NAME = 'Evoluent VerticalMouse C'

externalKeyboardIsConnected = false
externalMouseIsConnected = false
for _, device in pairs(hs.usb.attachedDevices()) do
  print(device.productName)
  if device.productName == EXTERNAL_KEYBOARD_NAME then
    externalKeyboardIsConnected = true
  elseif
    device.productName == EXTERNAL_MOUSE_NAME then
    externalMouseIsConnected = true
  end
end

-- These constants are used in the code below to allow hotkeys to be
-- assigned using side-specific modifier keys.
ORDERED_KEY_CODES = {58, 61, 55, 54, 59, 62, 56, 60}
KEY_CODE_TO_KEY_STR = {
  [58] = 'leftAlt',
  [61] = 'rightAlt',
  [55] = 'leftCmd',
  [54] = 'rightCmd',
  [59] = 'leftCtrl',
  [62] = 'rightCtrl',
  [56] = 'leftShift',
  [60] = 'rightShift',
}
KEY_CODE_TO_MOD_TYPE = {
  [58] = 'alt',
  [61] = 'alt',
  [55] = 'cmd',
  [54] = 'cmd',
  [59] = 'ctrl',
  [62] = 'ctrl',
  [56] = 'shift',
  [60] = 'shift',
}
KEY_CODE_TO_SIBLING_KEY_CODE = {
  [58] = 61,
  [61] = 58,
  [55] = 54,
  [54] = 55,
  [59] = 62,
  [62] = 59,
  [56] = 60,
  [60] = 56,
}

-- SIDE_SPECIFIC_HOTKEYS:
--     This table is used to setup my side-specific hotkeys, the format
--     of each entry is: {fromMods, fromKey, toMods, toKey}
--
--      Note: If you are trying to map from one key to that same key
--      with a different modifier (e.g. rightCmd+a -> ctrl+a), this
--      method won't work, but you can use the workaround mentioned
--      here: https://github.com/elliotwaite/hammerspoon-config/issues/1
--
--     fromMods (string):
--         Any of the following strings, joined by plus signs ('+'). If
--         multiple are used, they must be listed in the same order as
--         they appear in this list (alphabetical by modifier name, and
--         then left before right):
--             leftAlt
--             rightAlt
--             leftCmd
--             rightCmd
--             leftCtrl
--             rightCtrl
--             leftShift
--             rightSfhit
--
--     fromKey (string):
--         Any single-character string, or the name of a keyboard key.
--         The list keyboard key names can be found here:
--         https://www.hammerspoon.org/docs/hs.keycodes.html#map
--
--     toMods (string):
--         Any of the following strings, joined by plus signs ('+').
--         Unlike `fromMods`, the order of these does not matter:
--             alt
--             cmd
--             ctrl
--             shift
--             fn
--
--     toKey (string):
--         Same format as `fromKey`.
--
SIDE_SPECIFIC_HOTKEYS = {
  {'leftCmd', 'u', 'alt', 'left'},
  {'leftCmd+leftShift', 'u', 'alt+shift', 'left'},
  {'leftCmd', 'i', nil, 'up'},
  {'leftCmd+leftShift', 'i', 'cmd+shift', 'up'},
  {'leftCmd+rightShift', 'i', 'shift', 'up'},
  {'leftCmd+leftShift+rightShift', 'i', 'shift', 'up'},
  {'leftCmd', 'o', 'alt', 'right'},
  {'leftCmd+leftShift', 'o', 'alt+shift', 'right'},
  {'leftCmd', 'h', 'cmd', 'left'},
  {'leftCmd+leftShift', 'h', 'cmd+shift', 'left'},
  {'leftCmd', 'j', nil, 'left'},
  {'leftCmd+leftShift', 'j', 'shift', 'left'},
  {'leftCmd+rightShift', 'j', 'shift', 'left'},
  {'leftCmd', 'k', nil, 'down'},
  {'leftCmd+leftShift', 'k', 'cmd+shift', 'down'},
  {'leftCmd+rightShift', 'k', 'shift', 'down'},
  {'leftCmd+leftShift+rightShift', 'k', 'shift', 'down'},
  {'leftCmd', 'l', nil, 'right'},
  {'leftCmd+leftShift', 'l', 'shift', 'right'},
  {'leftCmd+rightShift', 'l', 'shift', 'right'},
  {'leftCmd', ';', 'cmd', 'right'},
  {'leftCmd+leftShift', ';', 'cmd+shift', 'right'},
  {'leftCmd', "'", 'cmd', 'right'},
  {'leftCmd+leftShift', "'", 'cmd+shift', 'right'},
}

hotkeyGroups = {}
for _, hotkeyVals in ipairs(SIDE_SPECIFIC_HOTKEYS) do
  local fromMods, fromKey, toMods, toKey = table.unpack(hotkeyVals)
  local toKeyStroke = function()
    hs.eventtap.keyStroke(toMods, toKey, 0)
  end
  local hotkey = hs.hotkey.new(fromMods, fromKey, toKeyStroke, nil, toKeyStroke)
  if hotkeyGroups[fromMods] == nil then
    hotkeyGroups[fromMods] = {}
  end
  table.insert(hotkeyGroups[fromMods], hotkey)
end

function updateEnabledHotkeys()
  if curHotkeyGroup ~= nil then
    for _, hotkey in ipairs(curHotkeyGroup) do
      hotkey:disable()
    end
  end

  local curModKeysStr = ''
  for _, keyCode in ipairs(ORDERED_KEY_CODES) do
    if modStates[keyCode] then
      if curModKeysStr ~= '' then
        curModKeysStr = curModKeysStr .. '+'
      end
      curModKeysStr = curModKeysStr .. KEY_CODE_TO_KEY_STR[keyCode]
    end
  end

  curHotkeyGroup = hotkeyGroups[curModKeysStr]
  if curHotkeyGroup ~= nil then
    for _, hotkey in ipairs(curHotkeyGroup) do
      hotkey:enable()
    end
  end
end

modStates = {}
for _, keyCode in ipairs(ORDERED_KEY_CODES) do
  modStates[keyCode] = false
end

modKeyWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
  local keyCode = event:getKeyCode()
  if modStates[keyCode] ~= nil then
    if event:getFlags()[KEY_CODE_TO_MOD_TYPE[keyCode]] then
      -- If a mod key of this type is currently pressed, we can't
      -- determine if this event was a key-up or key-down event, so we
      -- just toggle the `modState` value corresponding to the event's
      -- key code.
      modStates[keyCode] = not modStates[keyCode]
    else
      -- If no mod keys of this type are pressed, we know that this was
      -- a key-up event, so we set the `modState` value corresponding to
      -- this key code to false. We also set the `modState` value
      -- corresponding to its sibling key code (e.g. the sibling of left
      -- shift is right shift) to false to ensure that the state for
      -- that key is correct as well. This code makes the `modState`
      -- self correcting. If it ever gets in an incorrect state, which
      -- could happend if some other code triggers multiple key-down
      -- events for a single modifier key, the state will self correct
      -- once all modifier keys of that type are released.
      modStates[keyCode] = false
      modStates[KEY_CODE_TO_SIBLING_KEY_CODE[keyCode]] = false
    end
    updateEnabledHotkeys()
  end
end):start()


-- Remap [`] -> [escape] and [cmd + `] -> [`], but only when my external
-- keyboard is not connected. I use the grave accent key as my escape
-- key when using my laptop's built-in keyboard. And then when I
-- actually want to type a grave accent, I use [cmd + `].
graveAccentHotkey = hs.hotkey.new(nil, '`', function() hs.eventtap.keyStroke(nil, 'escape', 0) end)
cmdGraveAccentHotkey = hs.hotkey.new('cmd', '`', function() hs.eventtap.keyStrokes('`') end)

if not externalKeyboardIsConnected then
  graveAccentHotkey:enable()
  cmdGraveAccentHotkey:enable()
end

externalKeyboardWatcher = hs.usb.watcher.new(function(event)
  if event.productName == EXTERNAL_KEYBOARD_NAME then
    if event.eventType == 'added' then
      graveAccentHotkey:disable()
      cmdGraveAccentHotkey:disable()
    elseif event.eventType == 'removed' then
      graveAccentHotkey:enable()
      cmdGraveAccentHotkey:enable()
    end
  end
end):start()


-- A global hotkey that activates Chrome and opens a new tab. The hotkey
-- is set to [cmd + escape], but I have my caps lock key mapped to the
-- escape key using System Preferences > Keyboard > Modifier Keys, so
-- this hotkey is really for [cmd + caps lock].
hs.hotkey.bind('cmd', 'escape', function()
  hs.osascript.applescriptFromFile('openNewChromeTab.applescript')
end)


-- Remapped Chrome hotkeys.
chromeHotkeys = {
  -- Assign [cmd + 1] to toggle the developer tools.
  hs.hotkey.new('cmd', '1', function() hs.eventtap.keyStroke('alt+cmd', 'i', 0) end),
  -- Assign [cmd + 4] to toggle full screen mode.
  hs.hotkey.new('cmd', '4', function() hs.eventtap.keyStroke('cmd+ctrl', 'f', 0) end),
}

function enableChromeHotkeys()
  for _, hotkey in ipairs(chromeHotkeys) do
    hotkey:enable()
  end
end

function disableChromeHotkeys()
  for _, hotkey in ipairs(chromeHotkeys) do
    hotkey:disable()
  end
end

chromeWindowFilter = hs.window.filter.new('Google Chrome')
chromeWindowFilter:subscribe(hs.window.filter.windowFocused, enableChromeHotkeys)
chromeWindowFilter:subscribe(hs.window.filter.windowUnfocused, disableChromeHotkeys)

if hs.window.focusedWindow() and hs.window.focusedWindow():application():name() == 'Google Chrome' then
  -- If this script is initialized with a Chrome window already in
  -- focus, enable the Chrome hotkeys.
  enableChromeHotkeys()
end


-- In Davinci Resolve, remap [cmd + scroll] -> [alt + scroll].
davinciResolveScrollWatcher = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
  if event:getFlags():containExactly({'cmd'}) then
    event:setFlags({alt = true})
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


-- I swap the middle and right mouse button events when my external
-- mouse is connected.
--
-- Note: When I convert a middle button event to a right button event,
-- it gets recaught by the right button event handler. However, this
-- doesn't happend when converting right button events to middle button
-- events (perhaps this is due to the order in which Hammerspoon
-- processes the different event types). So to prevent the right button
-- event handler from undoing the initial event conversion, I set the
-- "eventSourceUserData" property to 1 when I convert a middle button
-- event to a right button event, and then whenever I recieve a right
-- button event, I check if the "eventSourceUserData" property is 1 to
-- determine if it actually came from the middle button event handler,
-- in which case I change the "evenSourceUserData" property back to 0
-- (the default value) and let it pass through. The choice of using the
-- "eventSourceUserData" porperty was arbitrary, it was just one of the
-- event properties that didn't seem like it was being used for anything
-- else (it was always 0), so I used it to pass data between the event
-- handlers.
mouseWatchers = {
  hs.eventtap.new({hs.eventtap.event.types.rightMouseDown}, function(event)
    if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == 1 then
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 0)
      return false
    end
    -- print('rightMouseDown')
    event:setType(hs.eventtap.event.types.otherMouseDown)
    event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)
  end),

  hs.eventtap.new({hs.eventtap.event.types.rightMouseUp}, function(event)
    if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == 1 then
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 0)
      return false
    end
    -- print('rightMouseUp')
    event:setType(hs.eventtap.event.types.otherMouseUp)
    event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)
  end),

  hs.eventtap.new({hs.eventtap.event.types.rightMouseDragged}, function(event)
    if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == 1 then
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 0)
      return false
    end
    -- print('rightMouseDragged')
    event:setType(hs.eventtap.event.types.otherMouseDragged)
    event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)
  end),

  hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(event)
    if event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 2 then
      -- print('middleMouseDown')
      event:setType(hs.eventtap.event.types.rightMouseDown)
      event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 1)
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
    end
  end),

  hs.eventtap.new({hs.eventtap.event.types.otherMouseUp}, function(event)
    if event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 2 then
      -- print('middleMouseUp')
      event:setType(hs.eventtap.event.types.rightMouseUp)
      event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 1)
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
    end
  end),

  hs.eventtap.new({hs.eventtap.event.types.otherMouseDragged}, function(event)
    if event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 2 then
      -- print('middleMouseDragged')
      event:setType(hs.eventtap.event.types.rightMouseDragged)
      event:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 1)
      event:setProperty(hs.eventtap.event.properties.eventSourceUserData, 1)
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

screenWidth = hs.screen:primaryScreen():fullFrame().w
screenWatcher = hs.screen.watcher.new(function()
  screenWidth = hs.screen:primaryScreen():fullFrame().w
end):start()

-- MENU_BAR_BUFFER = 15
-- isSlidingAlongTop = false
-- menuBarWatcher = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(event)
--   -- print('mouse moved')
--   -- print('delta',
--   --       event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX),
--   --       event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY))
--   point = hs.mouse.getAbsolutePosition()
--   -- print(point.x, point.y)
--   if isSlidingAlongTop then
--     if point.y > 23 then
--       isSlidingAlongTop = false
--     end
--   else
--     if point.y < MENU_BAR_BUFFER then
--       if point.x < MENU_BAR_BUFFER or point.x > screenWidth - MENU_BAR_BUFFER then
--         isSlidingAlongTop = true
--       else
--         -- print('delta x', event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX))
--         point.y = MENU_BAR_BUFFER
--         -- event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, 10)
--         -- print('keep')
--         -- point.x = point.x + event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
--         hs.mouse.setAbsolutePosition(point)
--         -- print('set it')
--         return true
--       end
--     end
--   end
--   -- print(even.getProperty[hs.eventtap.event.properties.])
-- end):start()



-- This code automatically realoads this hammer configutation file
-- whenever a file in the ~/.hammerspoon directory is changed, and shows
-- the alert, "Config reloaded," whenever it does. I enable this code
-- while debugging.
-- hs.loadSpoon('ReloadConfiguration')
-- spoon.ReloadConfiguration:start()
-- hs.alert.show('Config reloaded')