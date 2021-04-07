if application "Brave Browser" is running then
	tell application "Brave Browser"
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
	tell application "Brave Browser"
		activate
	end tell
end if