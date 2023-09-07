#!/bin/bash
animSpeed=.012   # delay between windows being minimized/restored; set to 0 to disable

main() {
    currDesktop=$(xdotool get_desktop)
    currFile="$HOME/.showDesktop_windows$currDesktop"
    currFocus=$(xdotool getactivewindow)

    noWindowsToMinize=1

    # check if there are any unminimized windows on current desktop
    while read -r line; do
        if !(xprop -id "$line" | grep -q "_NET_WM_STATE_HIDDEN"); then
            # if there are, minimize active windows and write their IDs to the file
            if [[ "$noWindowsToMinize" == "1" ]]; then
                noWindowsToMinize=0
                rm "$currFile"  # wipe previously saved windows
            fi
            xdotool windowminimize "$line" && echo "$line" >> "$currFile" && sleep $animSpeed
        fi
    done < <(echo "$(xdotool search --desktop "$currDesktop" --onlyvisible --name "")")

    if [[ "$noWindowsToMinize" == "0" ]]; then
        # if there are, add currently focused window (if there is one)
        # one more time, so it will be refocused when all windows are restored
        echo "$currFocus" >> "$currFile"

    # otherwise, try to restore all windows from the file (if it exists)
    elif [[ -f "$currFile" ]]; then
        while read -r line; do
            xdotool windowactivate "$line" && sleep $animSpeed
        done < "$currFile"
        rm "$currFile"
    else
        # if there are no windows to restore, open multitasking view
        dbus-send --session --dest=org.pantheon.gala --print-reply /org/pantheon/gala org.pantheon.gala.PerformAction int32:1
    fi
}

main