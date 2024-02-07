## Introduction
After numerous installations of Arch Linux, which seemed endless, I aimed to streamline the process. To avoid repetitive, manual command entry, I created a script. This script, enhanced with various features, simplifies my workflow and is universally applicable.

At the end, I'll publish it for you guys to use, because I think, that many of you have the problem as well.
I try to keep it updated so that it will work always with every iso.

<br>

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Custom ISO](#custom)

<br>

## Features
- [x] Different Desktop Environments
- [x] Drive selection 
- [x] Variable Swapfile Sizes
- [x] Username and password configurable
- [x] UEFI or Bios
- [ ] AUR Helper
- [ ] Multilib in pacman
- [ ] Disk/Partition Encryption

<br>

## Installation
```bash
curl -o archinstall.sh https://raw.githubusercontent.com/xXPerditorXx/linuxinstall/main/archinstall.sh
chmod +x archinstall.sh
./archinstall.sh
```
<br>

## Usage
Execute the installer bash script, and answer all the questions asked.

You need to know the following things:
- **Install Location**
- **Hostname**
- **Swapfile Size**
- **Root Password**
- **Username**
- **User Password**
- **Desktop Environment (Headless also possible)**
- **Keyboard Layout**
- **Locales**
- **Timezone**
- **AUR Helper** (in progress)
- **UEFI or BIOS**

After you entered them, you can lay back and depending on your internet speed take less than 4min for your archlinux installation.

## Custom
[Download Link](https://mega.nz/file/hpN2HZRY#HlZec2F4VIgUP11KMmoBSnvsfxFCojvwxkwIq_XKwv0)


<br>

ISO changes:
- Disabled startup sound
- Enabled Multilib in pacman.conf
- Enabled parallel downloads (3)
- Installed NeoVIM
- Added `xarchinstall`-alias for easy use of my install script

<br>

MD5:

bc81f9b39a5fc51eabf8a49e7a26b6c6

SHA1:

f16b51169be28e58bfc54458b195ab40ae1c5f41

SHA256: 

9bbece20d42a7bb08dfc117d49f621e27fe304ddbf75db0e8c9090c9312e5f25

SHA512: 

6da7331d21b2649e9b88699e5a698c87314c0f31cdd3e73364cad784a7a85bb904ed222389044b34f46a3d5235af1394c73c30d10d4952a6a0a87993aeffca7a
