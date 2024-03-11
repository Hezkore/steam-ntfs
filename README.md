# Linux Steam NTFS Auto-Setup

This is a Linux script designed to automate the process of configuring a NTFS disk, previously used in a Windows environment for Steam games, to work with Proton. This allows users to play the same games on both Windows and Linux without needing to reinstall them for each operating system.

This script aims to automate as much as possible from the Proton guide: [Using a NTFS disk with Linux and Windows](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows).

## Introduction

The script performs the following:

1. Verifies NTFS driver _(defaults to lowntfs-3g)_.
2. Verifies mount path _(defaults to /media/gamedisk)_.
3. Finds User ID and Group ID.
4. Checks availability of required tools.
5. Displays available block devices for user selection.
6. Finds UUID for the selected device.
7. Backs up fstab.
8. Writes data to fstab and creates mount point.
9. Attempts to mount the disk and verifies the result.

The script provides important information during and after its execution to help guide you through the process, and will not modify any files unless you give it permission to do so.

## Usage

To use the script, simply run it in your terminal.\
The script will guide you through the process and automate as much as possible.

## Note

If Windows is installed on the NTFS partition, the Windows Fast Startup feature can cause the mount command to fail.\
To prevent that, consider disabling it.

For more information, refer to this tutorial: [PassFab: Disable Fast Startup](https://www.passfab.com/windows-10/disable-fast-boot-windows-10.html#way3).