#!/bin/bash

repo_dir=$(dirname ${BASH_SOURCE[0]})

macos_tools=$repo_dir/macos-tools

if [[ ! -d $macos_tools || -d $macos_tools ]]; then
    echo "Downloading latest macos-tools..."
    rm -Rf $macos_tools && git clone https://github.com/the-braveknight/macos-tools $macos_tools --quiet
fi

downloads_dir=$repo_dir/Downloads
local_kexts_dir=$repo_dir/Kexts
hotpatch_dir=$repo_dir/Hotpatch/Downloads
themes_dir=$repo_dir/Themes
repo_plist=$repo_dir/org.stixzoor.s50b.plist

source $macos_tools/_hack_cmds.sh

case "$1" in
    --install-theme)
        EFI=$($macos_tools/mount_efi.sh)
        themes_dest=$EFI/EFI/CLOVER/themes
        echo "Copying HexagonDark to $themes_dest"
        cp -r $themes_dir/HexagonDark $themes_dest
    ;;
    --install-config)
        installConfig $repo_dir/config.plist
        $0 --install-theme
    ;;
    --install-initial-config)
        installConfig $repo_dir/config_install.plist
        $0 --install-theme
    ;;
    --update-config)
        updateConfig $repo_dir/config.plist
    ;;
esac
