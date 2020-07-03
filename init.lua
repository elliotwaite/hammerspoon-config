-- KEYMAP values format:
--     {fromMods, fromKey, toMods, toKey}
--
--     fromMods:
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
--     fromKey:
--         A string containing the name of a keyboard key (as found in
--         hs.keycodes.map (https://www.hammerspoon.org/docs/hs.keycodes.html#map)),
--         or a raw keycode number.
--
--     toMods:
--         Any of the following strings, joined by plus sings ('+'):
--             alt
--             cmd
--             ctrl
--             shift
--             fn
--
--     toKey:
--         A string containing the name of a keyboard key (as found in
--         hs.keycodes.map (https://www.hammerspoon.org/docs/hs.keycodes.html#map)),
--         or a raw keycode number.
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
NO_KEYS_PRESSED_FLAGS = 256

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

curHotkeyGroup = nil
function updateEnabledHotkeys()
  if curHotkeyGroup ~= nil then
    for _, hotkey in ipairs(curHotkeyGroup) do
      hotkey:disable()
    end
  end

  hotkeyGroupKey = ''
  for key_code, key_str in pairs(KEY_CODE_TO_KEY_STR) do
    if modStates[key_code] then
      if hotkeyGroupKey == '' then
        hotkeyGroupKey = key_str
      else
        hotkeyGroupKey = hotkeyGroupKey .. '+' .. key_str
      end
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
function initModStates()
  for key_code, _ in pairs(KEY_CODE_TO_KEY_STR) do
    modStates[key_code] = false
  end
end

modStatesAreReady = false
function tryToInitModState(pressedMods)
  -- We wait until the first time we encounter no mod keys being pressed
  -- before we start enabling hotkeys to ensure that our mode states
  -- table is correct. This is needed because this script may be
  -- initialized with mod keys already pressed.
  if not (pressedMods.alt or pressedMods.cmd or pressedMods.ctrl or pressedMods.shift) then
    for key_code, _ in pairs(KEY_CODE_TO_KEY_STR) do
      modStates[key_code] = false
    end
    modStatesAreReady = true
  end
end
tryToInitModState(hs.eventtap.checkKeyboardModifiers())

modkeyWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
  if not modStatesAreReady then
    tryToInitModState(event:getFlags())
  else
    local key_code = event:getKeyCode()
    if modStates[key_code] ~= nil then
      -- Toggle the current state of the triggered mod key.
      modStates[key_code] = not modStates[key_code]
      updateEnabledHotkeys()
    end
  end
end):start()


-- In DaVinci Resolve, remap cmd+scroll to alt+scroll.
davinciResolveScrollWatcher = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function (event)
  if event:getFlags():containExactly({'cmd'}) then
    event:setFlags({alt = true})
  end
end)

davinciResolveWindowFilter = hs.window.filter.new(function(win)
  return win:application():name() == 'DaVinci Resolve'
end)

davinciResolveWindowFilter:subscribe(hs.window.filter.windowFocused, function()
  davinciResolveScrollWatcher:start()
end)

davinciResolveWindowFilter:subscribe(hs.window.filter.windowUnfocused, function()
  davinciResolveScrollWatcher:stop()
end)

-- Hot reload for debugging.
-- hs.loadSpoon('ReloadConfiguration')
-- spoon.ReloadConfiguration:start()
-- hs.alert.show('Config reloaded')