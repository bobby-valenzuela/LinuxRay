#!/usr/bin/env bash

# Linux X-ray: Linux diagnostic tool.

# Author : Bobby Valenzuela
# Created : 27th November 2022
# Last Modified : 31st January 2023

# Description:
# Handles system cleanup tasks ans scans for violations of security best practices and performance detriments.
# Requires sudo privileges to run.

# If not root or sudoer...
{ [[ $(id -u) -eq 0 ]] || $(sudo -v &>/dev/null) ; } || { echo -e "Please run with sudo privileges.\nExiting..." ; exit 1 ; } 

sudo su -

# get top 5 process eating memory
ps auxf | sort -nr -k 4 | head -5
 
# get top 5 process eating cpu ##
ps auxf | sort -nr -k 3 | head -5

# Update cache and (maybe?) upgrade binaries
apt update 

# kill any running processes pointing to deleted files
lsof | grep -i deleted | tr -s [:space:] | cut -d ' ' -f 2 | xargs kill 



#######  TODO ########

# Make a systemd service of itself
# Dangling link cleanup
# old file archiver
# integrity checker
# critical disk usage (show top three large files)
# systemd-analyze blame (see which process tkes the longest to start pm boot)
# Check for any soft links not using absolute paths pointing to destination
# Check for any links
# load average (lscpu to see num cores)
# Clean Zombie processes
# Security checks
  #  Prone to fork bomb?
  # mysql --version to see if mysql/maris db is enabled and port is open on 3306.
  # check fstab for deice name instead of UUIDs
  # Listening on standard SSH port
  #  SSH see if root login is enabled
  # SSH see is password auth is accepted
  # use chage -l <username> to show last password change
  # - last time fsck was run?
  # w or who to see idle users for long time
  # lastb to see number of failed login attempts for past day
  # systemd mask to see if processes can start disabled processes?
  # print this in or Banner?
  # systemctl mask ctrl-alt-del.target (disable reboot hotley)
  # verify SSH file/dir permissions
  # git master/main preventkju
  # vscode cleanup 
  # John the ripper? 
  # package is cleanup 
  # c option too compress large text files (any greater than 100mb) 
