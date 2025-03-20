#!/bin/bash
fdisk -l
echo ""
echo "------------------------------------------------------"
echo "What is the path to the disk you want to install it on: "
read DRIVE
echo "Please enter your hostname: "
read HOSTNAME
echo "How much Swap in MB do you want to have: "
read SWAPSIZE
echo "Now, enter your root password: "
read ROOTPASSWD
echo "What should be your username: "
read USERNAME
echo "Give it a password: "
read USERPASSWD
echo "Which Window Manager do you want to install: KDE (k), GNOME (g), cutefish (c), Xfce (x), LXDE (l), Cinnamon (m), Headless (h)"
read DESKTOPENV
echo "Which keyboard layout do you want to use: (e.g. de-latin1, en, ru, neo, unicode)"
read CTRCODE
while true; do
        if localectl list-keymaps | grep -iq $CTRCODE;then
                break
        else
                echo "$CTRCODE was not found, try again."
                read CTRCODE
        fi
done

echo "Do you want to choose which locales should be generated: (leave blank for en_US.UTF-8)"
read LOCALES

echo "Enter your timezone: (e.g. Europe/Berlin, US/Central, America/Puerto_Rico, Singapore, Hongkong)"
read TIMEZONE
while true; do
    if [ -e "/usr/share/zoneinfo/$TIMEZONE" ]; then
        break
    else
        echo "Sorry, try again. $TIMEZONE is invalid"
        read TIMEZONE
    fi
done

echo "Install Uefi (u) or Bios (b)"
read option

timedatectl set-ntp true
wipefs -a -f $DRIVE
if [ "$option" == "u" ]; then
(
echo g;      # Erstellt eine neue leere GPT
echo n;      # Neue Partition
echo 1;      # Partition Nummer 1
echo ;       # Standard Startsektor
echo +256M;  # Endet 256MB später
echo t;      # Ändert den Partitionstyp
echo 1;      # Setzt auf einen neuen Typ
echo n;      # Neue Partition
echo 2;      # Partition Nummer 2
echo ;       # Standard Startsektor
echo ;       # Verwendet den verbleibenden Speicherplatz
echo w;      # Schreibt die Änderungen und beendet fdisk
) | fdisk $DRIVE
mkfs.ext4 ${DRIVE}2
mkfs.fat -F 32 ${DRIVE}1
mount ${DRIVE}2 /mnt
mkdir /mnt/efi
mount ${DRIVE}1 /mnt/efi
elif [ "$option" == "b" ]; then
(
echo o;      # Erstellt eine neue leere MBR
echo n;      # Neue Partition
echo p;      # Partitions Typ primary
echo 1;      # Partitionsnummer 1
echo ;       # Standard Startsektor
echo ;       # Bis zu letzden Sektor
echo t;      # Ändert den Partitionstyp
echo 82;      # Setzt auf einen neuen Typ
echo w;      # Schreibt die Änderungen und beendet fdisk
) | fdisk $DRIVE
mkfs.ext4 ${DRIVE}1
mount ${DRIVE}1 /mnt
else
    echo "Ungültige Auswahl."
fi
pacman-key --init
pacman-key --populate
echo -e "y\n" | pacman -Sy archlinux-keyring
(
echo 1;
echo 1;
echo y;
) | pacstrap -i /mnt base linux linux-firmware vim nano
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash -c "dd if=/dev/zero of=/swapfile bs=1M count=$SWAPSIZE status=progress"
arch-chroot /mnt /bin/bash -c "chmod 600 /swapfile"
arch-chroot /mnt /bin/bash -c "mkswap /swapfile"
arch-chroot /mnt /bin/bash -c "echo '/swapfile none swap sw 0 0' >> /etc/fstab"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
if [ -z "$LOCALES" ]; then
    arch-chroot /mnt /bin/bash -c "echo -e 'en_US.UTF-8 UTF-8' | tee -a /etc/locale.gen"
else
    echo "Press i to write, ESC > :wq to exit and write, if needed, /<search> to search"
    read
    vim /mnt/etc/locale.gen
fi
arch-chroot /mnt /bin/bash -c "locale-gen"
arch-chroot /mnt /bin/bash -c "echo LANG=en_US.UTF8 > /etc/locale.conf"
arch-chroot /mnt /bin/bash -c "echo KEYMAP=$CTRCODE > /etc/vconsole.conf"
arch-chroot /mnt /bin/bash -c "echo $HOSTNAME > /etc/hostname"
arch-chroot /mnt /bin/bash -c "echo -e '127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME' | tee -a /etc/hosts"
arch-chroot /mnt /bin/bash -c "echo -e 'y\n' | pacman -Syu networkmanager bash-completion linux-headers sudo iwd dialog wireless_tools wpa_supplicant mtools grub efibootmgr os-prober dosfstools base-devel memtest86+ memtest86+-efi"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "echo -e '$ROOTPASSWD\n$ROOTPASSWD' | passwd"
if [ "$option" == "u" ]; then
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --bootloader=GRUB --efi-directory=/efi"
elif [ "$option" == "b" ]; then
arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc $DRIVE"
else
    echo "Ungültige Auswahl."
fi
arch-chroot /mnt /bin/bash -c "sed -i '/^#GRUB_DISABLE_OS_PROBER=false/s/^#//' /etc/default/grub"
arch-chroot /mnt /bin/bash -c "sed -i 's/ quiet//' /etc/default/grub"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
arch-chroot /mnt /bin/bash -c "useradd -m -G wheel $USERNAME"
arch-chroot /mnt /bin/bash -c "echo -e '${USERPASSWD}\n${USERPASSWD}' | passwd $USERNAME"
arch-chroot /mnt /bin/bash -c "sed -i '/^# %wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers"

case $DESKTOPENV in
    "k")
        arch-chroot /mnt /bin/bash -c "echo -e '\n\n1\n1\n1\n1\n1\n1\n30\ny\n' | pacman -Syu xorg plasma-meta kde-applications sddm"
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm"
        arch-chroot /mnt /bin/bash -c "echo -e 'y\n' | pacman -R kmix"
        arch-chroot /mnt /bin/bash -c "exit"
        echo "kde installed."
        ;;
    "g")
        arch-chroot /mnt /bin/bash -c "echo -e '\n\n1\n1\n1\ny\n' | pacman -S gnome gnome-extra gdm"
        arch-chroot /mnt /bin/bash -c "systemctl enable gdm"
        arch-chroot /mnt /bin/bash -c "exit"
        echo "gnome installed."
        ;;
    "c")
        arch-chroot /mnt /bin/bash -c "echo -e '\n\n1\n1\n1\ny\n' | pacman -Syu cutefish xorg sddm firefox ttf-freefont kwrite vlc gwenview gimp libreoffice-still transmission-qt"
        arch-chroot /mnt /bin/bash -c "systemctl enable sddm"
        arch-chroot /mnt /bin/bash -c "exit"
        echo "cutefish installed."
        ;;
    "x")
        arch-chroot /mnt /bin/bash -c "echo -e '\n\n\n\n1\n1\n1\ny\n' | pacman -Syu xorg xfce4 xfce4-goodies lxdm firefox pulseaudio"
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm.service"
        arch-chroot /mnt /bin/bash -c "exit"
        echo "xfce installed."
        ;;
    "l")
        arch-chroot /mnt /bin/bash -c "echo -e '\ny\n' | pacman -Syu lxde"
        arch-chroot /mnt /bin/bash -c "systemctl enable lxdm"
        arch-chroot /mnt /bin/bash -c "exit"
        echo "lxdm installed."
        ;;
    "m")
        arch-chroot /mnt /bin/bash -c "echo -e '\n1\ny\n' | pacman -Syu xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings cinnamon system-config-printer gnome-keyring blueberry cups gnome-terminal"
        arch-chroot /mnt /bin/bash -c "systemctl enable lightdm bluetooth cups"
        arch-chroot /mnt /bin/bash -c "exit"
        echo "cinnamon installed."
        ;;
    "h")
        arch-chroot /mnt /bin/bash -c "exit"
        echo ""
        echo "------------------------------------------"
        echo "User requested no Desktop Environment."
        ;;
    *)
        arch-chroot /mnt /bin/bash -c "exit"
        echo ""
        echo "------------------------------------------"
        echo "$DESKTOPENV not found. Doing nothing..."
        ;;
esac
echo ""
echo "---------------------------------------------------"
echo "Your system has now been set up. When you're ready, just type 'umount -R /mnt ; reboot'"
