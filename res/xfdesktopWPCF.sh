sleep .3     # prevent cases when script was initialized too early
xfdesktop &

# change wallpaper function
wpChange() {
    wpname="$1"

    # since Switchboard doesn't support using different wallpaper for desktops,
    # we're focring xfdesktop to use one wallpaper for all workspaces,
    # no matter if the opposite xfdesktop option is enabled.
    /usr/bin/xfconf-query -l -c xfce4-desktop | grep "/backdrop/screen0/monitor.*/workspace.*/last-image" |
        while read -r line; do
            /usr/bin/xfconf-query -c xfce4-desktop -p "$line" -s "$wpname"
        done
}



# change xfdesktop wallpaper after every login
wpChange "$(gsettings get org.gnome.desktop.background picture-uri | sed -e "s/'file:\/\///" -e "s/%20/ /g" -e "s/'$//")"

# change xfdesktop wallpaper every time Gala desktop wallpaper is changed
/usr/bin/gsettings monitor org.gnome.desktop.background picture-uri |
    while read -r line; do
        wpChange "$(echo "$line" | sed -e "s/picture-uri: 'file:\/\///" -e "s/%20/ /g" -e "s/'$//")"
    done
