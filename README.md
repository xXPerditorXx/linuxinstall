## Introduction
After numerous installations of Arch Linux, which seemed endless, I aimed to streamline the process. To avoid repetitive, manual command entry, I created a script. This script, enhanced with various features, simplifies my workflow and is universally applicable.

At the end, I'll publish it for you guys to use, because I think, that many of you have the problem as well.
I try to keep it updated so that it will work always with every iso. Maybe, I'll even patch my own archlinux iso.

<br>

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)

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
