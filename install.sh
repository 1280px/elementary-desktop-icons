read -e -p $'Before the installation begins, please make sure you have these GTK style
patches installed (otherwise the desktop colors will be mismatched):

-- https://github.com/Romchec/elementary-OS-gtk2-support
-- https://github.com/Romchec/eOS-non-curated-apps-theme-integration

Do you want to continue the installation? [y/n] ' yn
if [[ "$yn" != "Y" && "$yn" != "y" ]] ; then exit 1 ; fi



# install all required binaries
# (thunar is required for background services)
sudo apt install xdotool xfdesktop4 thunar -y

# hide Thunar icons from Applications menu
echo "NoDisplay=True" >> ~/.local/share/applications/thunar.desktop &&
echo "NoDisplay=True" >> ~/.local/share/applications/thunar-bulk-rename.desktop

# copy xfdesktop wallpaper update script runner and add it to autorun for current user
sudo cp res/xfdesktopWU.sh /usr/local/ && sudo chmod 777 /usr/local/xfdesktopWU.sh
mkdir -p ~/.config/autostart && cp res/xfdesktopWU.desktop ~/.config/autostart/

# copy xfdesktop cosmetic patches for current user
mkdir -p ~/.config/gtk-3.0 && cp res/gtk.css ~/.config/gtk-3.0

# copy Open in Terminal fix for current user
mkdir -p ~/.config/Thunar && cp res/uca.xml ~/.config/Thunar

# copy Show Desktop script and add it to Super+D shortcut for current user
sudo cp res/showDesktop.sh /usr/local/ && sudo chmod 777 /usr/local/showDesktop.sh

dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customDesktop/binding "'<Super>d'" &&
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customDesktop/command "'/usr/local/showDesktop.sh'" &&
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings \
    "$(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings | \
    sed "s/]/, '\/org\/gnome\/settings-daemon\/plugins\/media-keys\/custom-keybindings\/customDesktop\/']/")"



# done :DDDD
notify-send "install.sh :: Done" "Installation finished! Please log out and log in again to apply the changes." -t 9999
