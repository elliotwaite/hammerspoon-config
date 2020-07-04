if application "Google Chrome" is running then
	tell application "Google Chrome"
		if (count every window) = 0 then
			make new window
		else
			reopen
			activate
			tell front window
				make new tab at end of tabs
			end tell
		end if
	end tell
else
	tell application "Google Chrome"
		activate
	end tell
end if