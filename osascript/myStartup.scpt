-- Keep in mind that while you can write the scripts in VS Code, you'll still need the Script Editor application to compile and run the scripts. The extension primarily helps with the writing and editing experience.


tell application "System Events"
    -- Launch your applications
    tell application "Microsoft Outlook" to activate
    delay 2 -- Add a delay to allow the app to launch

    tell application "Safari" to activate
    delay 2

    tell application "Notes" to activate
    delay 2

    -- Add more applications as needed
end tell
