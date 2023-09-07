read -e -p $'Before the installation begins, please make sure you have these GTK style
patches installed (otherwise, the desktop colors might be mismatched):

-- https://github.com/Romchec/elementary-OS-gtk2-support
-- https://github.com/Romchec/eOS-non-curated-apps-theme-integration

Do you want to continue the installation? [y/n] ' yn
if [[ "$yn" != "Y" && "$yn" != "y" ]]; then exit 1; fi



# install all required dependencies
aptToInstall="xdotool xfdesktop4 thunar"    # (thunar is required for background services)
echo -e "\n[i] Trying to install dependencies via apt: $aptToInstall"
sudo apt install $aptToInstall -y

# hide Thunar icons from Applications menu
echo "NoDisplay=True" >> ~/.local/share/applications/thunar.desktop &&
echo "NoDisplay=True" >> ~/.local/share/applications/thunar-bulk-rename.desktop

# copy xfdesktop wallpaper updater and add its launcher to autorun for current user
sudo cp res/xfdesktopWU.sh /usr/local/ && sudo chmod 777 /usr/local/xfdesktopWU.sh
mkdir -p ~/.config/autostart && cp res/xfdesktopWU.desktop ~/.config/autostart/

# copy xfdesktop cosmetic patches for current user
mkdir -p ~/.config/gtk-3.0 && cp res/gtk.css ~/.config/gtk-3.0

# copy xfdesktop config for current user,
# prevent from running in case of user updating/reinstalling the script
if [[ -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml ]]; then
    echo -e '\n[i] Skipped xfdesktop config file update because it already exists'
else
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml &&
    cp res/xfce4-desktop.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml
fi

# copy Open in Terminal fix for current user
mkdir -p ~/.config/Thunar && cp res/uca.xml ~/.config/Thunar



# copy Show Desktop script scheme depending on user choice
read -e -p $'\nPlease select Show Desktop scheme you want to use:

[1] Winlike -- copies Windows/KDE "Minimize all windows" behaviour.
    Opens multitasking view if there is nothing to minimize.
[2] Layered -- unique legacy scheme. Allows to peek at desktop
    and work with newly-opened apps. Once you\'re done, activate it
    again to layer new windows you need on top of the old ones.
[0] None -- do not install Show Desktop scheme.
    This will not uninstall the scheme if it was already installed.

You will be able to change your scheme later by simply running
install.sh again (it won\'t break anything!). Your choice: ' wl
if [[ "$wl" != "0" ]]; then
    if [[ "$wl" != "2" ]]; then
        showDesktopScheme="Winlike"
    else
        showDesktopScheme="Layered"
    fi

    sudo cp res/showDesktop_$showDesktopScheme.sh /usr/local/ &&
    sudo mv /usr/local/showDesktop_$showDesktopScheme.sh /usr/local/showDesktop.sh &&
    sudo chmod 777 /usr/local/showDesktop.sh

    # add selected Show Desktop scheme keystroke binding to Super+D,
    # prevent from running in case of user updating/reinstalling the script
    keystokesDPath="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    if !(echo "$(dconf read $keystokesDPath)" | grep -q "showDesktop"); then
        dconf write $keystokesDPath/showDesktop/binding "'<Super>d'" &&
        dconf write $keystokesDPath/showDesktop/command "'/usr/local/showDesktop.sh'" &&
        dconf write $keystokesDPath "$(
            if [[ $(echo "$(dconf read $keystokesDPath)") == "" || $(echo "$(dconf read $keystokesDPath)") == "@as []" ]];
            then
                echo "['$keystokesDPath/showDesktop/']" # for cases when no keystrokes exist
            else
                echo "$(dconf read $keystokesDPath | sed "s#]#, '$keystokesDPath/showDesktop/']#")"
            fi
        )"
    else
        echo -e '\n[i] Skipped Show Desktop keystroke installation because it already exists'
    fi
fi



# done :DDDD
notify-send "install.sh :: Done" "Installation finished! Please log out and log in again to apply the changes." -t 9999