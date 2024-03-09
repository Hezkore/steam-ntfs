#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: t; tab-width: 4 -*-

# Steam NTFS

NTFS_DRIVER="lowntfs-3g"
MOUNT_PATH="/media/gamedisk"
USER_ID=0
GROUP_ID=0

# Welcome
echo "============================"
echo "= Steam NTFS Configuration ="
echo
echo "This script will configure a NTFS disk containing Steam games, that was"
echo "previously used in a Windows environment, to work with Proton on Linux."
echo "Please make sure that the drive is properly mounted."
echo
echo "Press Enter to continue..."
read

# Check if the NTFS driver is installed by running it with --version
echo -n "Verifying NTFS driver \"$NTFS_DRIVER\"... "
if ! $NTFS_DRIVER --version > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find NTFS driver \"$NTFS_DRIVER\". Please install it." >&2
	exit 1
else
	echo "OK"
fi

# Check if path already exists
echo -n "Verifying mount path \"$MOUNT_PATH\"... "
if [ -d "$MOUNT_PATH" ]; then
	echo "WARNING"
	echo "Mount path \"$MOUNT_PATH\" already exists." >&2
else
	echo "OK"
fi

# Check so that fstab is in order
echo -n "Verifying \"/etc/fstab\"... "
if [ ! -f /etc/fstab ]; then
	echo "ERROR"
	echo "Cannot find \"/etc/fstab\"" >&2
	exit 1
fi
if grep -q "$MOUNT_PATH" /etc/fstab; then
	echo "ERROR"
	echo "Mount path \"$MOUNT_PATH\" already exists in \"/etc/fstab\"." >&2
	exit 1
else
	echo "OK"
fi

# Get the user ID
echo -n "Verifying user ID "
USER_ID=$(id -u)
if [ -z "$USER_ID" ]; then
	echo "ERROR"
	echo "Cannot get user ID." >&2
	exit 1
else
	echo -n "$USER_ID"
fi

# Get the group ID
echo -n " & group ID "
GROUP_ID=$(id -g)
if [ -z "$GROUP_ID" ]; then
	echo "ERROR"
	echo "Cannot get group ID." >&2
	exit 1
else
	echo "$GROUP_ID... OK"
fi

# Check of tools exist using whereis (check if where is exists too!)
echo -n "Verifying tools... "
# whereis
if ! which whereis > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find \"whereis\"." >&2
	exit 1
fi
# fdisk
if ! whereis fdisk > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find \"fdisk\"." >&2
	exit 1
fi
# blkid
if ! whereis blkid > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find \"blkid\"." >&2
	exit 1
fi
# grep
if ! whereis grep > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find \"grep\"." >&2
	exit 1
fi
# sed
if ! whereis sed > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find \"sed\"." >&2
	exit 1
fi
# sudo
if ! whereis sudo > /dev/null 2>&1; then
	echo "ERROR"
	echo "Cannot find \"sudo\"." >&2
	exit 1
fi

echo "OK"
echo
sudo echo -n

# Use lsblk to display block information
echo "Available block devices:"
echo
lsblk -f
echo
echo "Specify the NTFS partition where your Steam games are currently stored."
echo "This partition will be mounted later. (e.g., 'sda1')"
echo
echo -n "Partition: "
read DEVICE
DEVICE="/dev/$DEVICE"

# Get the UUID of the DEVICE
echo -n "Getting UUID for \"$DEVICE\"... "
UUID=$(sudo blkid -s UUID -o value $DEVICE)
if [ -z "$UUID" ]; then
	echo "ERROR"
	echo "Cannot get UUID of disk \"$DEVICE\". Make sure you entered the correct disk name." >&2
	exit 1
else
	echo "OK"
fi

# Announce that we are ready to configure fstab
echo
echo "==================================="
echo "= Ready to configure \"/etc/fstab\" ="
echo
echo "Using the following settings:"
echo "Mount path: $MOUNT_PATH"
echo "NTFS driver: $NTFS_DRIVER"
echo "UUID: $UUID"
echo "User ID: $USER_ID"
echo "Group ID: $GROUP_ID"
echo
echo "A backup of /etc/fstab will be made."
echo
echo "Press Enter to apply settings..."
read

# Make a copy of fstab
# If there's an existing backup we add a number
echo -n "Making a backup of /etc/fstab... "
backup_name="/etc/fstab.bak"
if [ -f $backup_name ]; then
	i=1
	while [ -f "${backup_name%.bak}$i.bak" ]; do
		i=$((i + 1))
	done
	backup_name="${backup_name%.bak}$i.bak"
fi
sudo cp /etc/fstab "$backup_name"
if [ -f "$backup_name" ]; then
	echo "OK"
else
	echo "ERROR"
	echo "Cannot make a backup of /etc/fstab." >&2
	exit 1
fi

# Append our data to fstab
echo -n "Appending data to /etc/fstab... "
sudo bash -c "echo '' >> /etc/fstab"
sudo bash -c "echo '# NTFS disk for Steam games' >> /etc/fstab"
sudo bash -c "echo 'UUID=$UUID $MOUNT_PATH $NTFS_DRIVER uid=$USER_ID,gid=$GROUP_ID,rw,user,exec,umask=000 0 0' >> /etc/fstab"

# Verify that the data was appended
if ! grep -q "$MOUNT_PATH" /etc/fstab; then
	echo "ERROR"
	echo "Cannot append data to /etc/fstab." >&2
	exit 1
else
	echo "OK"
fi

# Create the mount path
echo -n "Creating mount path \"$MOUNT_PATH\"... "
sudo mkdir -p "$MOUNT_PATH"
if [ -d "$MOUNT_PATH" ]; then
	echo "OK"
else
	echo "ERROR"
	echo "Cannot create mount path \"$MOUNT_PATH\"." >&2
	exit 1
fi

# Configuration complete
echo
echo "DONE!"
echo
echo "Press Enter for important information..."
read

# IMPORTANT INFORMATION
echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! IMPORTANT INFORMATION !"

# Inform user that if anything goes wrong he should use the fstab backup, then wait for input
echo
echo "If anything goes wrong, you can restore the backup of /etc/fstab with:"
echo "sudo cp $backup_name /etc/fstab"
echo "Take a photo of this or write it down!"
echo
echo "Press Enter for more information..."
read

# Inform the user about fast startup in Windows
echo "If you have fast startup enabled in Windows, you should disable it."
echo "Fast startup can cause the disk to be in an inconsistent state when mounting it in Linux."
echo "Visit https://www.passfab.com/windows-10/disable-fast-boot-windows-10.html#way3 for instructions."
echo
echo "Press Enter for more information..."
read

# Inform user that a reboot is required
echo "A reboot is required for the changes to take effect."
echo "The disk should be mounted at \"$MOUNT_PATH\" after the reboot."
echo
echo "You can then add the disk to Steam by going to:"
echo "Settings -> Storage -> and in the drop down menu, select Add Drive."
echo
echo "Press Enter to continue..."
read

# Ask if the user wants to inspect the fstab file
echo -n "Do you want to inspect \"/etc/fstab\" now? (y/n) "
read INSPECT
if [ "$INSPECT" != "n" ]; then
	# if "less" is installed, we use that, otherwise we cat it
	if whereis less > /dev/null 2>&1; then
		sudo less /etc/fstab
	else
		sudo cat /etc/fstab
	fi
fi

echo
echo "Remember the $backup_name backup in case anything goes wrong!"

# Exit
exit