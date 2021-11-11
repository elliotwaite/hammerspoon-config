screenWidth = hs.screen:primaryScreen():fullFrame().w
screenWatcher = hs.screen.watcher.new(function()
  screenWidth = hs.screen:primaryScreen():fullFrame().w
end):start()

MENU_BAR_BUFFER = 15
isSlidingAlongTop = false
menuBarWatcher = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(event)
  -- print('mouse moved')
  -- print('delta',
  --       event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX),
  --       event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY))
  point = hs.mouse.getAbsolutePosition()
  -- print(point.x, point.y)
  if isSlidingAlongTop then
    if point.y > 23 then
      isSlidingAlongTop = false
    end
  else
    if point.y < MENU_BAR_BUFFER then
      if point.x < MENU_BAR_BUFFER or point.x > screenWidth - MENU_BAR_BUFFER then
        isSlidingAlongTop = true
      else
        -- print('delta x', event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX))
        point.y = MENU_BAR_BUFFER
        -- event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, 10)
        -- print('keep')
        -- point.x = point.x + event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
        hs.mouse.setAbsolutePosition(point)
        -- print('set it')
        return true
      end
    end
  end
  -- print(even.getProperty[hs.eventtap.event.properties.])
end):start()