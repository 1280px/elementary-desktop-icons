sleep .3        # prevent cases when script gets initialized too early
xfdesktop &     # (try making this value bigger if xfdesktop doesn't load on startup)


# update wallpaper function
wpUpdate() {
    wpImage=$(echo ${1} | sed "s/^'file:\/\///; s/%20/ /g; s/'$//")
    wpStyle=$(echo ${2} | sed "s/'//g")

    # get current workspace if different settings
    # for multiple workspaces are ON, otherwise use primary
    if (/usr/bin/xfconf-query -c xfce4-desktop -p "/backdrop/single-workspace-mode" | grep -q "true"); then
        currWorkspaceID=$(/usr/bin/xfconf-query -c xfce4-desktop -p "/backdrop/single-workspace-number")
    else
        currWorkspaceID=$(xdotool get_desktop)
    fi


    # change wallpaper image for given desktop of all displays
    /usr/bin/xfconf-query -l -c xfce4-desktop | grep "/backdrop/screen0/monitor.*/workspace${currWorkspaceID}/last-image" |
        while read -r line; do
            /usr/bin/xfconf-query -c xfce4-desktop -p "$line" -s "$wpImage"
        done

    # change wallpaper style for given desktop of all displays
    case "$wpStyle" in
        # we only care about cases that are possible to select in Switchboard
        'centered') wpStyleID=1 ;;
        'spanned') wpStyleID=3 ;;
        'none') wpStyleID=0 ;;
        *) wpStyleID=5 ;;       # use 'zoom' as fallback value
    esac
    /usr/bin/xfconf-query -l -c xfce4-desktop | grep "/backdrop/screen0/monitor.*/workspace${currWorkspaceID}/image-style" |
        while read -r line; do
             /usr/bin/xfconf-query -c xfce4-desktop -p "$line" -s "$wpStyleID"
        done


    echo -e "UPDATED XFDESKTOP WORKSPACE #$currWorkspaceID PROPERTIES: \n  wpImage :: $wpImage\n  wpStyle :: $wpStyle\n\n"
}


# update xfdesktop wallpaper when started,
# if different settings for multiple workspaces are OFF
if (/usr/bin/xfconf-query -c xfce4-desktop -p "/backdrop/single-workspace-mode" | grep -q "true"); then
    wpUpdate "$(gsettings get org.gnome.desktop.background picture-uri)" \
             "$(gsettings get org.gnome.desktop.background picture-options)"
fi

# update xfdesktop wallpaper every time Gala desktop wallpaper is changed
gsettings monitor org.gnome.desktop.background |
    while read -r line; do
        # check for "picture-uri: " and "picture-options: " keys
        if (echo "$line" | grep -q -e "^picture-uri: " -e "^picture-options: "); then
            wpUpdate "$(gsettings get org.gnome.desktop.background picture-uri)" \
                     "$(gsettings get org.gnome.desktop.background picture-options)"
        fi
    done
