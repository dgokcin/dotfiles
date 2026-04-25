on run argv
  set targetCWD to item 1 of argv

  tell application "iTerm2"
    repeat with aWindow in windows
      repeat with aTab in tabs of aWindow
        repeat with aSession in sessions of aTab
          try
            set sessionPath to variable named "path" of aSession
            if sessionPath starts with targetCWD then
              select aWindow
              tell aWindow to select aTab
              activate
              return
            end if
          end try
        end repeat
      end repeat
    end repeat
    -- fallback: just activate iTerm2
    activate
  end tell
end run
