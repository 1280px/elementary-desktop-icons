#!/bin/bash
animSpeed=.012   # delay between windows being minimized/restored; set to 0 to disable

main() {
    # get current desktop and current desktop file
    currDesktop=$(xdotool get_desktop)
    currFile="$HOME/.showDesktop_windows$currDesktop"
    echo "TRYING TO OPEN FILE: $currFile ..."

    # check if there are saved windows for this desktops
    if [[ -f "$currFile" ]];

    # if the file exists, try to restore all windows by their IDs in file and remove it;
    # if no windows from the file exist, delete the file and run the script again
    then
        echo "  FILE EXISTS, TRYING TO RESTORE WINDOWS..."
        # remember windows that were visible before the restoration routine
        echo $(xdotool search --desktop "$currDesktop" --onlyvisible --name "")

        noWindowsFound=1
        while read -r line; do
            xdotool windowactivate "$line" && noWindowsFound=0 && sleep $animSpeed
        done < "$currFile"
        rm "$currFile"

        if [[ "$noWindowsFound" == "1" ]]; then
            echo "    NO WINDOWS FOUND, RESTARTING THE SCRIPT..."
            main
        else
            # push up all the windows that were active before the routine began
            echo "$currWindows" |
                while read -r line; do
                    if !(xprop -id "$line" | grep -q "_NET_WM_STATE_HIDDEN"); then
                        xdotool windowactivate "$line"
                    fi
                done
        fi

    # if the file does not exist,
    # minimize active windows on this desktop and write their IDs to the file
    else
        echo "  FILE DOES NOT EXIST, MINIMIZING ALL WINDOWS..."
        # get all windows on current desktop
        xdotool search --desktop "$currDesktop" --onlyvisible --name "" |
            # sadly, there is no easy way to check if a window is minimized
            # through xdotool, so we have to use xprop as well
            while read -r line; do
                if !(xprop -id "$line" | grep -q "_NET_WM_STATE_HIDDEN"); then
                    xdotool windowminimize "$line" && echo "$line" >> "$currFile" && sleep $animSpeed
                fi
            done
    fi

    echo "ROUTINE FINISHED."
}

# start the script when executed
main
