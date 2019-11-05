#!/usr/bin/env bash

OS_Version="${$(sw_vers -productVersion):0:5}"

repo_dir=$(dirname ${BASH_SOURCE[0]})

macos_tools=$repo_dir/macos-tools

if [[ ! -d $macos_tools ]]; then
    echo "Downloading latest macos-tools..."
    rm -Rf $macos_tools && git clone https://github.com/the-braveknight/macos-tools $macos_tools --quiet
fi

themes_dir=$repo_dir/Themes
system_dir=$repo_dir/System
config_install_plist=$repo_dir/config_install.plist

helper="MountSystem"
helper_load="com.stixzoor.MountSystem.plist"
helper_exec=$system_dir/$helper
helper_plist=$system_dir/$helper_load

source $macos_tools/_hack_cmds.sh

function installMountSystemHelper() {
    echo "Installing MountSystem helper tool"

    sudo cp  $helper_exec /usr/local/bin/
    sudo cp  $helper_plist /Library/LaunchDaemons/
        
    sudo chmod 755 /usr/local/bin/$helper
    sudo chown $USER:admin /usr/local/bin/$helper
    sudo chmod 644 /Library/LaunchDaemons/$helper_load
    sudo chown root:wheel /Library/LaunchDaemons/$helper_load

    sudo launchctl load /Library/LaunchDaemons/$helper_load
}

case "$1" in
    --auto-mode)
        $0 --mount-system
        $0 --download-requirements
        $0 --install-downloads
    ;;
    --mount-system)
        if [[ "${OS_Version}" -eq "10.15" ]]; then
            sudo mount -uw /
            sudo killall finder
        fi
    ;;
    --install-mount-system-helper)
        if [[ "${OS_Version}" -eq "10.15" ]]; then
            installMountSystemHelper
        else
            echo "This is only for use in Mac OS Catalina."
            exit 0
        fi
    --install-theme)
        EFI=$($macos_tools/mount_efi.sh)
        themes_dest=$EFI/EFI/CLOVER/themes
        echo "Copying HexagonDark to $themes_dest"
        cp -r $themes_dir/HexagonDark $themes_dest
    ;;
    --install-initial-config)
        installConfig $config_install_plist
        $0 --install-theme
    ;;
esac
