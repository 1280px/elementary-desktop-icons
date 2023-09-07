#!/bin/bash
animSpeed=.012   # delay between windows being minimized/restored; set to 0 to disable

main() {
    # get current desktop and current desktop file
    currDesktop=$(xdotool get_desktop)
    currFile="$HOME/.showDesktop_windows$currDesktop"

    # check if there are restorable saved windows for this desktop
    if [[ -f "$currFile" ]];

    # if the file exists, try to restore all windows by their IDs in file and remove it;
    # if no windows from the file exist, delete the file and run the script again
    then
        currWindows=$(xdotool search --desktop "$currDesktop" --onlyvisible '')
        currFocus=$(xdotool getactivewindow)
    
        noWindowsFound=1
        while read -r line; do
            xdotool windowactivate "$line" && noWindowsFound=0 && sleep $animSpeed
        done < "$currFile"
        rm "$currFile"

        # restart script if there are no windows to restore
        if [[ "$noWindowsFound" == "1" ]]; then main
        else
            # push up all windows that were active before the routine began
            echo "$currWindows" |
                while read -r line; do
                    if !(xprop -id "$line" | grep -q "_NET_WM_STATE_HIDDEN"); then
                        xdotool windowactivate "$line"
                    fi
                done
            # finally, restore focus on the window that was focused before
            xdotool windowactivate "$currFocus"
        fi

    # if the file does not exist,
    # minimize active windows and write their IDs to the file
    else
        xdotool search --desktop "$currDesktop" --onlyvisible --name '' |
            while read -r line; do
                if !(xprop -id "$line" | grep -q "_NET_WM_STATE_HIDDEN"); then
                    xdotool windowminimize "$line" && echo "$line" >> "$currFile" && sleep $animSpeed
                fi
            done
    fi
}

main