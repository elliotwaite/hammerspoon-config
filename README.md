# My Hammerspoon Settings

My Hammerspoon configuration file sets up the following rules. See my [init.lua](https://github.com/elliotwaite/hammerspoon-config/blob/master/init.lua)
file for more details.

The following keys get remapped so that they can be used for navigation:
* `leftCmd + i` → `up`
* `leftAlt + i` → `cmd + up` (scroll to top of page)
* `leftCmd + k` → `down`
* `leftAlt + k` → `cmd + down` (scroll to bottom of page)
* `leftCmd + j` → `left`
* `leftCmd + u` → `alt + left` (left one word)
* `leftCmd + h` → `cmd + left` (jump to beginning of line)
* `leftCmd + l` → `right`
* `leftCmd + o` → `alt + right` (right one word)
* `leftCmd + ;` or `'` → `cmd + right` (jump to end of line)
* `leftCmd + ;` or `'` → `cmd + right` (jump to end of line)

I also map `alt + scroll` to scroll to the top or bottom of the page by
multiplying the scroll distances by 1,000. This is better than just
mapping to `cmd + up/down` because this allows you to scroll to the
top/bottom of pages that are not in focus but are hovered over by the
cursor:
* `alt + scroll up` → `scroll up 1,000x` (scroll to top of page)
* `alt + scroll down` → `scroll down 1,000x` (scroll to bottom of page)

And I use [Mos](https://mos.caldis.me) to map `cmd + scroll` to
scrolling in the same direction but faster:
* `cmd + scroll up` → `scroll up faster`
* `cmd + scroll down` → `scroll down faster`

The following hotkeys are enabled when my external keyboard is not connected:
* ``` ` ``` → `escape`
* ```cmd + ` ``` → ``` ` ```

Global hotkeys:
* `cmd + escape` → Activate Brave and open a new tab. (Note:
  I have my `caps lock` key remapped to `escape` in `System Preferences >
  Keyboard > Modifier Keys`, so for me, this hotkey is really activated
  by `cmd + caps lock`)

Remapped browser hotkeys (for both Brave and Chrome):
* `cmd + 1` → `alt + cmd + i` (Toggle the developer tools)
* `cmd + 4` → `cmd + ctrl + f` (Toggle full screen mode)

Remapped Davinci Resolve events:
* `cmd + scroll` → `alt + scroll` (so that I can use `cmd + scroll` to zoom in an out of the timeline)

I also swap my middle and right mouse button events (I use an Evoluent
vertical mouse, and the Evoluent mouse driver is currently broken in Big
Sur, so I use Hammerspoon to remap the buttons instead). And I map the
extra thumb buttons to swipe gestures:
* `rightMouseDown` → `middleMouseDown`
* `rightMouseUp` → `middleMouseUp`
* `rightMouseDragged` → `middleMouseDragged`
* `middleMouseDown` → `rightMouseDown`
* `middleMouseUp` → `rightMouseUp`
* `middleMouseDragged` → `rightMouseDragged`
* `mouseButton4Down` → `swipeLeft`
* `mouseButton3Down` → `swipeRight`

My YouTube Video about Hammerspoon: https://youtu.be/wpVNm8Ub-1s

[<img src="https://img.youtube.com/vi/wpVNm8Ub-1s/hqdefault.jpg">](https://www.youtube.com/watch?v=wpVNm8Ub-1s)

Note: If you are trying to map from one key to that same key with a
different modifier (e.g. `rightCmd + a` → `ctrl + a`), the default
method I use in my code to setup the above mappings won't work, but you
can use the workaround mentioned here:
https://github.com/elliotwaite/hammerspoon-config/issues/1

## License

[MIT](LICENSE)
