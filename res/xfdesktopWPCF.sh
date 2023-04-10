# start xfdesktop
xfdesktop & disown xfdesktop 

# change the xfdesktop wallpaper after login
/usr/bin/xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/last-image -s "$(gsettings get org.gnome.desktop.background picture-uri | sed -e "s/'file:\/\///" -e "s/%20/ /g" -e "s/'$//")"

# change the xfdesktop wallpaper every time Gala desktop wallpaper is changed
/usr/bin/gsettings monitor org.gnome.desktop.background picture-uri |
    while read -r line; do
        /usr/bin/xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/last-image -s "$(echo "$line" | sed -e "s/picture-uri: 'file:\/\///" -e "s/%20/ /g" -e "s/'$//")"
    done

notify-send -u "critical" "(dies from cringe)"



