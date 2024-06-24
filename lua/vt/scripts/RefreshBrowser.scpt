tell application "Brave"
  activate
  delay 0.2
  tell application "System Events" to keystroke "r" using command down
  tell application "Warp" to activate
end tell
