read -e -p $'
Before the installation begins, it is recommended
(but not necessary) to install these GTK style patches:

-- https://github.com/Romchec/elementary-OS-gtk2-support
-- https://github.com/Romchec/eOS-non-curated-apps-theme-integration

Do you want to continue the installation? [y/n] ' yn
if [[ "$yn" != "Y" && "$yn" != "y" ]]; then exit 1; fi



read -e -p $'
Please select the desktop you want to install:

[1] nemo-desktop (DEFAULT) -- uses Nemo in background;
    Does not require a separate script for synchronizing
    desktop wallpaper preferences with Gala desktop.

[2] xfdesktop4 -- uses XFCE4 Thunar in background;
    Requires constantly running a separate script for syncing
    desktop wallpaper preferences with Gala desktop.

You can read more about each desktop pros and cons
in the README. Your choice: ' c_desktop

# apply cosmetic patches for current user
mkdir -p ~/.config/gtk-3.0 && cp res/gtk.css ~/.config/gtk-3.0

if [[ "$c_desktop" != "2" ]]; then
    echo -e '\n[i] Installing minimal dependencies (risky!)...'
    # original nemo apt package is over 200 MB, however,
    # because we only care about the desktop, we can
    # install just the core packages & save around 180 MB!
    deps=(
        "libexempi8" "libgail-3-0"
        "libxapp1" "xapps-common" "xapp"
        "cinnamon-desktop-data" "libcinnamon-desktop4"
        "libnemo-extension1" "nemo-data" "nemo" 
    )
    for dep in "${deps[@]}"; do
        sudo apt download "$dep" &&
        sudo dpkg -i ./"$dep"_*.deb &
        rm -f ./"$dep"_*.deb
    done

    # remove unwanted .desktop files
    sudo echo "NoDisplay=True" >> /usr/share/applications/nemo.desktop

    # add nemo-desktop to autorun for current user
    mkdir -p ~/.config/autostart && cp res/nemo.desktop ~/.config/autostart/

    # fix Open in Terminal action
    gsettings set org.cinnamon.desktop.default-applications.terminal exec \
        $(gsettings get org.gnome.desktop.default-applications.terminal exec)

else
    echo -e '\n[i] Installing full dependencies via apt...'
    deps="xdotool xfdesktop4 thunar"
    sudo apt install $deps -y

    # TODO: remove unwanted .desktop files
    sudo echo "NoDisplay=True" >> /usr/share/applications/thunar.desktop &&
    sudo echo "NoDisplay=True" >> /usr/share/applications/thunar-bulk-rename.desktop

    # copy wallpaper updater and add its launcher to autorun for current user
    sudo cp res/xfdesktopWU.sh /usr/local/ && sudo chmod 777 /usr/local/xfdesktopWU.sh
    mkdir -p ~/.config/autostart && cp res/xfdesktopWU.desktop ~/.config/autostart/

    # copy default configs for current user,
    # prevent from running in case of user updating/reinstalling the script
    if [[ -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml ]]; then
        echo -e '\n[i] Skipped xfdesktop config file update because it already exists'
    else
        mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml &&
        cp res/xfce4-desktop.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml
    fi

    # copy Open in Terminal fix for current user
    mkdir -p ~/.config/Thunar && cp res/uca.xml ~/.config/Thunar
fi



read -e -p $'
Now, select the Show Desktop scheme you want to use:

[1] Winlike (DEFAULT) -- copies Windows/KDE "Minimize all windows".
    Opens multitasking view if there is nothing to minimize.

[2] Layered -- unique legacy scheme. Allows to peek at desktop
    and work with newly-opened apps. Once you are done, activate it
    again to layer new windows you need on top of the old ones.

[0] None -- do not install Show Desktop scheme.
    This will NOT uninstall the scheme if it is already installed.

The scheme, if installed, will also be automatically bound
to "Super + D" keystroke (if available). Your choice: ' c_showdesk

# copy Show Desktop script scheme depending on user choice
if [[ "$c_showdesk" != "0" ]]; then
    if [[ "$c_showdesk" != "2" ]]; then
        showDesktopScheme="Winlike"
    else
        showDesktopScheme="Layered"
    fi

    sudo cp res/showDesktop_$showDesktopScheme.sh /usr/local/ &&
    sudo mv /usr/local/showDesktop_$showDesktopScheme.sh /usr/local/showDesktop.sh &&
    sudo chmod 777 /usr/local/showDesktop.sh

    # add selected Show Desktop scheme keystroke binding to Super + D,
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
echo -e '\nInstallation finished! Please log out and log back in to apply the changes.'
