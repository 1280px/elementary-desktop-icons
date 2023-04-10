sleep .3        # prevent cases when script gets initialized too early
xfdesktop &     # (try making this value bigger if xfdesktop doesn't load on startup)

# update wallpaper function
wpUpdate() {
    wpImage=$(echo ${1} | sed "s/^'file:\/\///; s/%20/ /g; s/'$//")
    wpStyle=$(echo ${2} | sed "s/'//g")
    wpColor=$(echo ${3} | sed "s/'//g") # TODO: not implemented (see line 29)

    # change wallpaper image for all displays
    /usr/bin/xfconf-query -l -c xfce4-desktop | grep "/backdrop/screen0/monitor.*/workspace0/last-image" |
        while read -r line; do
            /usr/bin/xfconf-query -c xfce4-desktop -p "$line" -s "$wpImage"
        done
    
    # change wallpaper style for all displays
    case "$wpStyle" in
        # we only care about cases that are possible to select in Switchboard
        'centered') wpStyleID=1 ;;
        'spanned') wpStyleID=3 ;;
        'none') wpStyleID=0 ;;
        *) wpStyleID=5 ;;       # use 'zoom' as fallback value
    esac
    /usr/bin/xfconf-query -l -c xfce4-desktop | grep "/backdrop/screen0/monitor.*/workspace0/image-style" |
        while read -r line; do
            /usr/bin/xfconf-query -c xfce4-desktop -p "$line" -s "$wpStyleID"
        done
    
    # TODO: change primary color for all displays
    # (xfce stores RGBA colors as 4-value array and I'm not sure how to work with it)
    #/usr/bin/xfconf-query -l -c xfce4-desktop | grep "/backdrop/screen0/monitor.*/workspace0/rgba1" |
    #    while read -r line; do
    #        /usr/bin/xfconf-query -c xfce4-desktop -p "$line" -s "$wpColor"
    #    done
}



# update xfdesktop wallpaper when started
wpUpdate "$(gsettings get org.gnome.desktop.background picture-uri)" \
         "$(gsettings get org.gnome.desktop.background picture-options)" \
         "$(gsettings get org.gnome.desktop.background primary-color)"

# update xfdesktop wallpaper every time Gala desktop wallpaper is changed
gsettings monitor org.gnome.desktop.background |
    while read -r line; do
        # check for "picture-uri: ", "picture-options: " and "primary-color: " keys
        if echo "$line" | grep -q -e "^picture-uri: " -e "^picture-options: " -e "^primary-color: "; then

            wpUpdate "$(gsettings get org.gnome.desktop.background picture-uri)" \
                     "$(gsettings get org.gnome.desktop.background picture-options)" \
                     "$(gsettings get org.gnome.desktop.background primary-color)"
        fi
    done
