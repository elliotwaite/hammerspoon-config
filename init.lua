-- A helper function for debuggins.
-- local inspect = require('inspect')
-- function p(x)
--   print('Inspect:')
--   print(inspect(x))
-- end

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

EXTERNAL_KEYBOARD_NAME = 'Advantage2 Keyboard'


-- KEYMAP values format:
--     {fromMods, fromKey, toMods, toKey}
--
--     fromMods (string):
--         Any of the following strings, joined by plus sings ('+'). If
--         multiple are used, they must be in the same order as they
--         appear in this list:
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
--         A string containing the name of a keyboard key (as found in
--         hs.keycodes.map (https://www.hammerspoon.org/docs/hs.keycodes.html#map)),
--         or a raw keycode number.
--
--     toMods (string):
--         Any of the following strings, joined by plus sings ('+'):
--             alt
--             cmd
--             ctrl
--             shift
--             fn
--
--     toKey (string):
--         Same format as fromKey.
--
KEYMAP = {
  {'leftCmd', 'u', 'alt', 'left'},
  {'leftCmd+leftShift', 'u', 'alt+shift', 'left'},
  {'leftCmd', 'i', nil, 'up'},
  {'fn', 'a', nil, 'up'},
  {'leftCmd+leftShift', 'i', 'cmd+shift', 'up'},
  {'leftCmd+rightShift', 'i', 'shift', 'up'},
  {'leftCmd+leftShift+rightShift', 'i', 'shift', 'up'},
  {'leftCmd', 'o', 'alt', 'right'},
  {'leftCmd+leftShift', 'o', 'alt+shift', 'right'},
  {'leftCmd', 'h', 'cmd', 'left'},
  {'leftCmd+leftShift', 'h', 'cmd+shift', 'left'},
  {'leftCmd', 'j', nil, 'left'},
  {'leftCmd+leftShift', 'j', 'shift', 'left'},
  {'leftCmd', 'k', nil, 'down'},
  {'leftCmd+leftShift', 'k', 'cmd+shift', 'down'},
  {'leftCmd+rightShift', 'k', 'shift', 'down'},
  {'leftCmd+leftShift+rightShift', 'k', 'shift', 'down'},
  {'leftCmd', 'l', nil, 'right'},
  {'leftCmd+leftShift', 'l', 'shift', 'right'},
  {'leftCmd', ';', 'cmd', 'right'},
  {'leftCmd+leftShift', ';', 'cmd+shift', 'right'},
  {'leftCmd', "'", 'cmd', 'right'},
  {'leftCmd+leftShift', "'", 'cmd+shift', 'right'},
  {'leftCmd', 'm', nil, '['},
  {'leftCmd+leftShift', 'm', 'shift', '['},
  {'leftCmd', ',', 'shift', '9'},
  {'leftCmd', '.', 'shift', '0'},
  {'leftCmd', '/', nil, ']'},
  {'leftCmd+leftShift', '/', 'shift', ']'},
}

hotkeyGroups = {}
for _, hotkeyVals in ipairs(KEYMAP) do
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

  local hotkeyGroupKey = ''
  for _, keyCode in ipairs(ORDERED_KEY_CODES) do
    if modStates[keyCode] then
      if hotkeyGroupKey ~= '' then
        hotkeyGroupKey = hotkeyGroupKey .. '+'
      end
      hotkeyGroupKey = hotkeyGroupKey .. KEY_CODE_TO_KEY_STR[keyCode]
    end
  end

  curHotkeyGroup = hotkeyGroups[hotkeyGroupKey]
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
        -- If a mod key of this type is pressed, we don't know if it is
        -- the right or the left one, so we can't determine if this is a
        -- key-up or key-down event, so we just toggle the `modState`
        -- value corresponding to this key code.
        modStates[keyCode] = not modStates[keyCode]
      else
        -- If no mod key of this type is pressed, we know that it is a
        -- key-up event, so we set the `modState` value corresponding to
        -- this key code to false.
        modStates[keyCode] = false
      end
      updateEnabledHotkeys()
    end
end):start()


-- Remap [`] -> [escape] and [cmd + `] -> [`], but only when my external
-- keyboard is not connected.
graveAccentHotkey = hs.hotkey.bind(nil, '`', function() hs.eventtap.keyStroke(nil, 'escape', 0) end)
cmdGraveAccentHotkey = hs.hotkey.bind('cmd', '`', function() hs.eventtap.keyStrokes('`') end)
for _, device in pairs(hs.usb.attachedDevices()) do
  if device.productName == EXTERNAL_KEYBOARD_NAME then
    graveAccentHotkey:disable()
    cmdGraveAccentHotkey:disable()
    break
  end
end

usbWatcher = hs.usb.watcher.new(function(event)
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


-- A global hotkey that activates Chrome opens a new tab. Below the
-- hotkey is set to [cmd + escape], but I have caps lock mapped to the
-- escape key using System Preferences > Keyboard > Modifier Keys, so
-- this hotkey is really for [cmd + caps lock].
hs.hotkey.bind('cmd', 'escape', function()
  hs.osascript.applescriptFromFile('openNewChromeTab.applescript')
end)


-- Chrome hotkeys.
chromeHotkeys = {
  -- Toggle developer tools [cmd + 1].
  hs.hotkey.new('cmd', '1', function() hs.eventtap.keyStroke('alt+cmd', 'i') end),
  -- Toggle full screen mode [cmd + 3].
  hs.hotkey.new('cmd', '3', function() hs.eventtap.keyStroke('cmd+ctrl', 'f') end),
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

if hs.window.focusedWindow():application():name() == 'Google Chrome' then
  enableChromeHotkeys()
end

chromeWindowFilter = hs.window.filter.new('Google Chrome')
chromeWindowFilter:subscribe(hs.window.filter.windowFocused, enableChromeHotkeys)
chromeWindowFilter:subscribe(hs.window.filter.windowUnfocused, disableChromeHotkeys)


-- In Davinci Resolve, remap [cmd + scroll] -> [alt + scroll].
davinciResolveScrollWatcher = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
  if event:getFlags():containExactly({'cmd'}) then
    event:setFlags({alt = true})
  end
end)

davinciResolveWindowFilter = hs.window.filter.new(function(win)
  -- Here we use a custom function because the DaVinci Resolve window
  -- is not detected for some reason when it is fullscreen mode if we
  -- try to use: hs.window.filter.new('DaVinci Resolve')
  return win:application():name() == 'DaVinci Resolve'
end)

davinciResolveWindowFilter:subscribe(hs.window.filter.windowFocused, function()
  davinciResolveScrollWatcher:start()
end)

davinciResolveWindowFilter:subscribe(hs.window.filter.windowUnfocused, function()
  davinciResolveScrollWatcher:stop()
end)


-- For hot reloading.
-- hs.loadSpoon('ReloadConfiguration')
-- spoon.ReloadConfiguration:start()
-- hs.alert.show('Config reloaded')