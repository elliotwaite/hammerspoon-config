# My Hammerspoon Settings

My Hammerspoon configuration file sets up the following rules. See my [init.lua](https://github.com/elliotwaite/hammerspoon-config/blob/master/init.lua)
file for more details.

I map `alt + scroll` to scroll to the top or bottom of the page by multiplying
the scroll distances by 1,000. This is better than just mapping to `cmd +
up/down` because this allows you to scroll to the top/bottom of pages that are
not in focus but are hovered over by the cursor:
* `alt + scroll up` → `scroll up 1,000x` (scroll to top of page)
* `alt + scroll down` → `scroll down 1,000x` (scroll to bottom of page)

I also use [Mos](https://mos.caldis.me) to map `cmd + scroll` to
scrolling in the same direction but faster:
* `cmd + scroll up` → `scroll up faster`
* `cmd + scroll down` → `scroll down faster`

In Davinci Resolve, I map:
* `cmd + scroll` → `alt + scroll` (so that I can use `cmd + scroll` to zoom in
  an out of the timeline)

In Sublime Text, I map:
* `cmd + scroll` → `scroll` (to avoid an issue with Sublime Text where it
  ignores `cmd + scroll` events)

In PyCharm, I map:
* `cmd + enter` → `cmd + alt + 0` (which I set up as a PyCharm hotkey for
  "Complete Current Statement"). And then the script checks if the last
  character of the line the caret ends up on is a semicolon, and if it is, a
  return key event is fired to insert a new line.

My YouTube Video about Hammerspoon: https://youtu.be/wpVNm8Ub-1s

[<img src="https://img.youtube.com/vi/wpVNm8Ub-1s/hqdefault.jpg">](https://www.youtube.com/watch?v=wpVNm8Ub-1s)

## License

[MIT](LICENSE)
