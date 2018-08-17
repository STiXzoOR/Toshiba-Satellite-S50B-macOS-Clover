#!/bin/bash

#set -x

downloads=Downloads

local_kexts_dir=Kexts
kexts_dir=$downloads/Kexts

kexts_exceptions="Sensors|FakePCIID_BCM57XX|FakePCIID_Intel_GbX|FakePCIID_Intel_HDMI|FakePCIID_Intel_HD_Graphics|FakePCIID_XHCIMux|FakePCIID_AR9280_as_AR946x|BrcmFirmwareData|PatchRAM.kext|NonPatchRAM2.kext|PS2"

tools_dir=$downloads/Tools

hotpatch_dir=Hotpatch/Downloads

hda_codec=CX20756
hda_resources=Resources_$hda_codec

ps2_trackpad=$(ioreg -n PS2Q -arxw0 > /tmp/ps2_trackpad.plist && /usr/libexec/PlistBuddy -c "Print :0:name" /tmp/ps2_trackpad.plist)

if [[ "$ps2_trackpad" == *"SYN"* ]]; then
    ps2_kext=VoodooPS2Controller.kext
else
    ps2_kext=ApplePS2SmartTouchPad.kext
fi

if [[ ! -d macos-tools ]]; then
    echo "Downloading latest macos-tools..."
    rm -Rf macos-tools && git clone https://github.com/the-braveknight/macos-tools --quiet
fi

function showOptions() {
    echo "--download-requirements,  Download required kexts, hotpatches and tools."
    echo "--install-downloads,  Install kext(s) and tool(s)."
    echo "--install-config,  Install the config to EFI/CLOVER."
    echo "--update-config,  Update the existing config in EFI/CLOVER."
    echo "--update-kernelcache,  Update kernel cache."
    echo "-i,  inlude custom kexts while using --download-requirements option."
    echo "-h,  Show this help message."
    echo "Usage: $(basename $0) [--download-requirements -i <Author exact name:Kext(s) exact name> separated by |]"
    echo "Example: $(basename $0) --download-requirements -i 'lvs1974:HibernationFixup,AirportBrcmFixup|acidanthera:Lilu,AppleALC'"
}

function findKext() {
    find $kexts_dir $local_kexts_dir -name $1 -not -path \*/PlugIns/* -not -path \*/Debug/*
}

case "$1" in
    --download-tools)
        rm -Rf $tools_dir && mkdir -p $tools_dir

        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-maciasl-patchmatic -o $tools_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-maciasl-patchmatic -f RehabMan-patchmatic -o $tools_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n acpica -o $tools_dir
    ;;
    --download-kexts)
        rm -Rf $kexts_dir && mkdir -p $kexts_dir

        # Bitbucket kexts
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-fakesmc-kozlek -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-realtek-network -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-fake-pci-id -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-voodoo-ps2-controller -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-acpi-battery-driver -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-brcmpatchram -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-usb-inject-all -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -n os-x-eapd-codec-commander -o $kexts_dir

        # GitHub kexts
        macos-tools/github_download.sh -u acidanthera -r Lilu -o $kexts_dir
        macos-tools/github_download.sh -u acidanthera -r WhateverGreen -o $kexts_dir

        subcommand=$1; shift
        while getopts ":i:" option; do
            case $option in
            i)
                include_kexts=$OPTARG
            ;;
            ?)
                showOptions
                exit 0
            ;;
            esac
        done
        IFS="|" read -ra myArr <<< "$include_kexts"
        for author_kexts in "${myArr[@]}"; do
            IFS=":" read author kexts <<< "$author_kexts"
            for kext_name in $(echo $kexts | tr "," "\n"); do
                macos-tools/github_download.sh -u $author -r $kext_name -o $kexts_dir
            done
        done
    ;;
    --download-hotpatch)
        rm -Rf $hotpatch_dir && mkdir -p $hotpatch_dir

        macos-tools/hotpatch_download.sh -o $hotpatch_dir SSDT-IGPU.dsl
        macos-tools/hotpatch_download.sh -o $hotpatch_dir SSDT-HDAU.dsl
        macos-tools/hotpatch_download.sh -o $hotpatch_dir SSDT-PNLF.dsl
        macos-tools/hotpatch_download.sh -o $hotpatch_dir SSDT-XOSI.dsl
        macos-tools/hotpatch_download.sh -o $hotpatch_dir SSDT-DEHCI.dsl
    ;;
    --install-apps)
        macos-tools/unarchive_file.sh -d $tools_dir
        macos-tools/install_app.sh -d $tools_dir
    ;;
    --install-binaries)
        macos-tools/unarchive_file.sh -d $tools_dir
        macos-tools/install_binary.sh -d $tools_dir
    ;;
    --install-kexts)
        macos-tools/unarchive_file.sh -d $kexts_dir
        macos-tools/install_kext.sh -d $kexts_dir -e $kexts_exceptions
        $0 --install-hdainjector
        $0 --install-backlightinjector
        $0 --install-ps2kext
        $0 --install-sdkext
        $0 --update-kernelcache
    ;;
    --install-essential-kexts)
        macos-tools/unarchive_file.sh -d $kexts_dir
        EFI=$(macos-tools/mount_efi.sh)
        kext_dest=$EFI/EFI/CLOVER/kexts/Other
        rm -Rf $kext_dest/*.kext
        macos-tools/install_kext.sh -s $kext_dest $(findKext FakeSMC.kext) $(findKext RealtekRTL8111.kext) $(findKext FakePCIID.kext) $(findKext FakePCIID_Broadcom_WiFi.kext) $(findKext USBInjectAll.kext) $(findKext ACPIBatteryManager.kext) $(findKext $ps2_kext)
    ;;
    --install-hdainjector)
        macos-tools/create_hdainjector.sh -c $hda_codec -r $hda_resources -o $local_kexts_dir
        macos-tools/install_kext.sh $local_kexts_dir/AppleHDA_$hda_codec.kext
    ;;
    --install-backlightinjector)
        macos-tools/install_kext.sh $local_kexts_dir/AppleBacklightInjector.kext
    ;;
    --install-ps2kext)
        sudo rm -Rf /Library/Extensions/ApplePS2SmartTouchPad.kext
        sudo rm -Rf /Library/Extensions/VoodooPS2Controller.kext

        macos-tools/install_kext.sh $(findKext $ps2_kext)
    ;;
    --install-sdkext)
        macos-tools/install_kext.sh $local_kexts_dir/Sinetek-rtsx.kext
    ;;
    --update-kernelcache)
        sudo kextcache -i /
    ;;
    --install-config)
        macos-tools/install_config.sh config.plist
    ;;
    --update-config)
        macos-tools/install_config.sh -u config.plist
    ;;
    --update)
        echo "Checking for updates..."
        git stash --quiet && git pull
        echo "Checking for macos-tools updates..."
        cd macos-tools && git stash --quiet && git pull && cd ..
    ;;
    --download-requirements)
        $0 --download-kexts $2 $3
        $0 --download-tools
        $0 --download-hotpatch
    ;;
    --install-downloads)
        $0 --install-binaries
        $0 --install-apps
        $0 --install-essential-kexts
        $0 --install-kexts
    ;;
esac
