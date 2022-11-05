#!/bin/bash

source cosmetics
source UUID.txt

#######################################################################################
#
# Post installation script
# (You are now logged in as $USER)
######################################################################################## 
cosmetics

# Installing i3WM
	
	info_print "Synchronizing pacman repositories..."
	sudo pacman -Syy
	clear
	
	info_print "Installing i3 WM's..." 
	sudo pacman -S --noconfirm --needed xorg xorg-xinit i3-gaps i3lock i3status dmenu xfce4-terminal firefox picom nitrogen lxappearance archlinux-wallpaper arc-gtk-theme materia-gtk-theme papirus-icon-theme
	clear
	sudo cp /etc/X11/xinit/xinitrc ~/.xinitrc
	sudo chown $USER:$USER .xinitrc
	sed -i '51,55d' .xinitrc
	echo "## Compositor" >> .xinitrc
	echo "/usr/bin/picom -f &" >> .xinitrc
	echo ""
	echo "## Resolution" >> .xinitrc
	echo "xrandr --output Virtual-1 --mode 1920x1080 &" >> .xinitrc
	echo ""
	echo "Wallpaper restore" >> .xinitrc
	echo "/usr/bin/nitrogen --restore &" >> .xinitrc

	echo "## Start i3" >> .xinitrc
	echo "exec i3" >> .xinitrc

	info_print "i3WM installation is now complete!"
	input_print "Press any key to continue..."
	read -n 1 -s -r

#####################################################################

# Enable AUR Helper (paru-bin)

#info_print "Installing AUR helper (paru-bin)"
#mkdir AUR
#cd AUR
#git clone https://aur.archlinux.org/paru-bin.git
#cd paru-bin
#makepkg -sic
#clear

# Enable booting from Snapshots in GRUB Menu
info_print "Enabling booting from GRUB Menu snapshots..."
#paru -Sa --noconfirm snap-pac-grub
#sudo grub-mkconfig -o /boot/grub/grub.cfg
#clear
git clone https://aur.archlinux.org/snap-pac-grub.git
cd snap-pac-grub
makepkg -si
clear

# Create base configuration snapshot
info_print "Taking a snapshot: Base System Configuration..."
sudo snapper -v -c root create -t single -d "*** Initial Base System Configuration ***"

# Enable & Start periodic execution of btrfs scrub
info_print "Enable & Start Periodic execution of btrfs scrub..."
output=$(sudo systemd-escape --template btrfs-scrub@.timer --path /dev/disk/by-uuid/$root_uuid)
sudo systemctl enable $output
sudo systemctl start $output
clear

# Enable and Start the timeline snapshots timer
info_print "Enable & Start timeline snapshots timer..."
sudo systemctl enable snapper-timeline.timer
sudo systemctl start snapper-timeline.timer
clear

# Enable and Start  the timeline cleanup timer
info_print "Enable & Start timeline snapshots cleanup timer..."
sudo systemctl enable snapper-cleanup.timer
sudo systemctl start snapper-cleanup.timer
clear

# Edit snapper configuration file"
info_print "Editing snapper configuration file..."
sudo mv /etc/snapper/configs/root .
sed -i 's|QGROUP=""|QGROUP="1/0"|' root
sed -i 's|NUMBER_LIMIT="50"|NUMBER_LIMIT="10-35"|' root
sed -i 's|NUMBER_LIMIT_IMPORTANT="50"|NUMBER_LIMIT_IMPORTANT="15-25"|' root
sed -i 's|TIMELINE_LIMIT_HOURLY="10"|TIMELINE_LIMIT_HOURLY="5"|' root
sed -i 's|TIMELINE_LIMIT_DAILY="10"|TIMELINE_LIMIT_DAILY="5"|' root
sed -i 's|TIMELINE_LIMIT_WEEKLY="0"|TIMELINE_LIMIT_WEEKLY="2"|' root
sed -i 's|TIMELINE_LIMIT_MONTHLY="10"|TIMELINE_LIMIT_MONTHLY="3"|' root
sed -i 's|TIMELINE_LIMIT_YEARLY="10"|TIMELINE_LIMIT_YEARLY="0"|' root
sudo mv root /etc/snapper/configs/
info_print "Updating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg
clear
info_print "Post-install configuration is now completed!"
info_print "You may now reboot..."
input_print "Press any key to continue..."
read -n 1 -s -r
exit

