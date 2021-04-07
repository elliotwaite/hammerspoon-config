# My Hammerspoon Settings

My Hammerspoon configuration file sets up the following rules. See my [init.lua](https://github.com/elliotwaite/hammerspoon-config/blob/master/init.lua)
file for more details.

When the left command key is pressed, the following keys get remapped so
that they can be used for
navigation:
* `i` → `up`
* `k` → `down`
* `j` → `left`
* `l` → `right`
* `u` → `alt + left` (left one word)
* `o` → `alt + right` (right one word)
* `h` → `cmd + left` (beginning of line)
* `;` or `'` → `cmd + right` (end of line)

Note: If you are trying to map from one key to that same key
with a different modifier (e.g. rightCmd+a -> ctrl+a), the default
method I use in my code to setup the above mappings won't work,
but you can use the workaround mentioned here:
https://github.com/elliotwaite/hammerspoon-config/issues/1

The following hotkeys are enabled when my external keyboard is not connected:
* ``` ` ``` → `escape`
* ```cmd + ` ``` → ``` ` ```

Global hotkeys:
* `cmd + escape` → Activate Brave and open a new tab. (Note:
  I have my `caps lock` key remapped to `escape` in `System Preferences >
  Keyboard > Modifier Keys`, so for me, this hotkey is really activated
  by `cmd + caps lock`)

Remapped Brave hotkeys:
* `cmd + 1` → `alt + cmd + i` (Toggle the developer tools)
* `cmd + 4` → `cmd + ctrl + f` (Toggle full screen mode)

Remapped Davinci Resolve events:
* `cmd + scroll` → `alt + scroll` (so that I can use `cmd + scroll` to zoom in an out of the timeline)

I swap my middle and right mouse button events (I use an Evoluent
vertical mouse, and the Evoluent mouse driver is currently broken in Big
Sur, so I use Hammerspoon to remap the buttons instead):
* `rightMouseDown` → `middleMouseDown`
* `rightMouseUp` → `middleMouseUp`
* `rightMouseDragged` → `middleMouseDragged`
* `middleMouseDown` → `rightMouseDown`
* `middleMouseUp` → `rightMouseUp`
* `middleMouseDragged` → `rightMouseDragged`

My YouTube Video about Hammerspoon: https://youtu.be/wpVNm8Ub-1s

[<img src="https://img.youtube.com/vi/wpVNm8Ub-1s/hqdefault.jpg">](https://www.youtube.com/watch?v=wpVNm8Ub-1s)

## License

[MIT](LICENSE)
