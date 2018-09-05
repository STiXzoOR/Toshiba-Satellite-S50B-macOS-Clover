# Pre-Install

## Necessities:
* 8GB+ USB stick
* Computer running MacOS (If you do not have a computer running MacOS, ask a friend/family member or check out how to make a Virtual Machine running MacOS on windows [here](https://techsviewer.com/install-macos-high-sierra-vmware-windows/).)
* A lot of time (remember: This is not something you do in 30 minutes and are done with forever.)
* A copy of the **full** High Sierra or Mojave installer

## Step 1 - Making a bootable USB
Open up Disk Utility and select your USB **drive**, not the partition, and click erase. 

(If you cannot see your drive, click on show in the top left corner and select "Drives".)

For "Format", you want to select MacOS Extended (journaled) or APFS (journaled). For "Partition Scheme", you want to select "GUID Partition Table". Click Erase and wait until the process is finished. 

(If the process fails, try again. This has happened to me several times on (High) Sierra's Disk Utility with different PCs.)

Rename your USB to "install_osx".

## Step 2
Open up App Store on your MacOS VM or computer and search for Install High Sierra (hotlink [here](https://itunes.apple.com/us/app/macos-high-sierra/id1246284741?mt=12))

Check if you have the full installer, the size should be 4.8GB in total.

Open Terminal and run the following command

For Mojave: 
```
sudo "/Applications/Install macOS Mojave Beta.app/Contents/Resources/createinstallmedia" --volume /Volumes/install_osx --nointeraction
```

For High Sierra: 
```
sudo "/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia" --volume /Volumes/install_osx --nointeraction
```

This will make a bootable USB to install macOS with, let the process run until it finishes.

## Step 3 - Install Clover
Download the latest version of clover from [here](https://github.com/Dids/clover-builder/releases) (click `Clover_vx.x_rxxxx.pkg`, should be ~18mb)

Right click (or CMD+click) on the package and click Open, you will get a prompt telling you that the software is from an unidentified developer instead. ([how to disable this](http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/))

Click Continue, Continue, Agree and Agree. Now, click Customize and select the following:

For booting Clover UEFI:
```
- check "Install for UEFI booting only", "Install Clover in the ESP" will automatically select
- check "HFSPlus", "AptioMemoryFix-64" and "EmuVariableUefi-64" from "UEFI Drivers"
- if you are installing in APFS mode, check "ApfsDriverLoader-64" from "UEFI Drivers"
- most systems will work without DataHubDxe-64.efi, but some may require it
```

For booting Clover Legacy:
```
- check "Install Clover in the ESP"
- in "Bootloader", check "Install boot0af in MBR" ("Install boot0ss in MBR" for HDD install if dual-boot Windows)
- "CloverEFI" should be checked
```

## Step 3 - Downloading Kexts
We are now going to install some kernel extensions (often referred to as "kexts") necessary for booting at all. 

To start, the developer tools must be installed, if you don't have them already. Run Terminal, and type:
```
git
```

You will be prompted to install the developer tools. Since you have internet working, you can choose to have it download and install them automatically. Do that before continuing.
After the developer tools are installed, we need to make a copy of the project on github.

In Terminal:
```
mkdir ~/Projects
cd ~/Projects
git clone https://github.com/STiXzoOR/Toshiba-Satellite-S50B-macOS s50b.git
cd s50b.git
```

To download the kexts & tools, in Terminal:
```
./wizard.sh --download-requirements
```

To install kexts to EFI, in Terminal:
```
./wizard.sh --install-essential-kexts
```

## Step 4 - Pre-configured config.plist

To install the pre-configured config.plst to EFI, in Terminal:
```
./wizard.sh --install-initial-config
```

## Step 5 - BIOS/UEFI settings

Change the following settings before you boot into the macOS installer:

* Exit → System Defaults [F9]: Yes
* Security → Secure Boot: Disabled
* Power Managements → Wake Up LAN: Disabled
* Power Managements → Wake On Keyboard: Disabled
* Power Managements → Critical Battery Wake Up: Enabled
* Power Managements → Panel Open Power On: Disabled
* Power Managements → Power On By AC: Disabled
* Power Managements → Dynamic CPU Frequency Mode: Dynamic Switch
* Power Managements → Intel Turbo Boost: Enabled
* Power Managements → SATA Interface Technology: Performance
* Advanced → USB Power in Sleep Mode: Disabled
* Advanced \ System Configuration → Boot Mode: UEFI Boot

## Step 6 - Patching BIOS

Since macOS Yosemite, Apple raised the minimum stolen memory in the AppleIntelBDWGraphicsFramebuffer binary. Kernel panic will happen if the DVMT pre-allocated memory in BIOS settings is lower than 66MB and the default value of DVMT pre-allocated memory in most laptops BIOS is 32MB. However on laptops, the DVMT pre-allocated value can't be changed through BIOS so you have to patch it by following the steps below.

1. Prepare USB with EFI Shell 
  * Download [EFI shell](http://www.firewolf.science/wp-content/uploads/2015/04/EFI-shell.zip).
  * Format it in **FAT32** filesystem.
  * Copy **BOOT** folder to your USB stick.
2. Dump current BIOS file
  * Download [Universal BIOS Backup Toolkit](http://m.majorgeeks.com/files/details/universal_bios_backup_toolkit.html) (Windows version only). 
  * Run it as an **ADMIN**.
  * Press **READ**. 
  * Wait until it has finished.
  * Press **BACKUP** and save it as **BIOS.rom**.
3. Extract SETUP Binary file
  * Download [UEFITools](https://github.com/LongSoft/UEFITool/releases).
  * Open the **BIOS** file that you saved previously. 
  * Find the module labeled with **SetupUtility** and extract the **PE32 image** section﻿ in this module as a binary file.
4. Convert SETUP Binary file to plain text
  * Download [Universal IFR Extractor﻿](https://github.com/LongSoft/Universal-IFR-Extractor/releases) (Windows version only). 
  * Open the Universal IFR Extractor and load the binary file you just extracted from UEFITools.
  * Click **EXTRACT** to save the **BIOS** settings in plain text format.
5. Find DVMT variable and value
  * Open the extracted **SetupIFR.txt** and find the keyword **"DVMT"**.
  * Mark down the DVMT variable and 96MB value. Example: variable=0x18C and value=0x3.
6. Boot into EFI Shell
  * Reboot system.
  * Plug USB.
  * Boot into EFI Shell.
7. Change DVMT value
  * Type in EFI Shell: setup_var variable value. Replace **variable** and **value** with the DVMT variable and value you found above.
  * Reboot system. 

All done! You can now boot into the macOS installer.
Checkout how to install macOS on a mac [here](https://support.apple.com/en-us/HT204904).
