read -e -p $'Before the installation begins, please make sure you have these GTK style
patches installed (otherwise, the desktop colors might be mismatched):

-- https://github.com/Romchec/elementary-OS-gtk2-support
-- https://github.com/Romchec/eOS-non-curated-apps-theme-integration

Do you want to continue the installation? [y/n] ' yn
if [[ "$yn" != "Y" && "$yn" != "y" ]] ; then exit 1 ; fi



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

# copy Open in Terminal fix for current user
mkdir -p ~/.config/Thunar && cp res/uca.xml ~/.config/Thunar

# copy Show Desktop script and add it to Super+D keystroke for current user
sudo cp res/showDesktop.sh /usr/local/ && sudo chmod 777 /usr/local/showDesktop.sh

keystokesDPath="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
# prevent from running in case of user updating/reinstalling the script
if !(echo "$(dconf read $keystokesDPath)" | grep -q "showDesktop"); then
    dconf write $keystokesDPath/showDesktop/binding "'<Super>d'" &&
    dconf write $keystokesDPath/showDesktop/command "'/usr/local/showDesktop.sh'" &&
    dconf write $keystokesDPath "$(
        if [[ $(echo "$(dconf read $keystokesDPath)") == "" || $(echo "$(dconf read $keystokesDPath)") == "@as []" ]]; then
            echo "['$keystokesDPath/showDesktop/']"  # for cases when no keystrokes exist
        else
            echo "$(dconf read $keystokesDPath |
            sed "s#]#, '$keystokesDPath/showDesktop/']#")"
        fi
    )"
else
    echo -e '\n[i] Skipped Show Desktop keystroke installation because it already exists'
fi



# done :DDDD
notify-send "install.sh :: Done" "Installation finished! Please log out and log in again to apply the changes." -t 9999
