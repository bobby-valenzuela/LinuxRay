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


# **********************************************************
#           FUNCTIONS
# **********************************************************

# Get count of characters wide the terminal is
COLUMNS=$(tput cols)

prHeader(){

    for each in $(seq 1 $COLUMNS)

    do

    echo -n $1

    done

}

prHeaderLeftHalf(){
    for each in $(seq 1 $(($COLUMNS/2)))

    do

      echo -n $1

    done

    echo

}

prHeaderLeftThird(){
    for each in $(seq 1 $(($COLUMNS/3)))

    do

      echo -n $1

    done

    echo

}

prHeaderLeftQuarter(){
    for each in $(seq 1 $(($COLUMNS/4)))

    do

      echo -n $1

    done

    echo

}

prtxtCentre(){

  title=$1

  printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"

}





# print colored text
print_colored()
{

    [[ -z "$1" ||  -z "$2" ]] && echo "Usage: print_colored <color> <text>" && exit 1
    
    auto_print_newline=''
    [[ "$3" == 'no' ]] && auto_print_newline='-n' 

    case "$1" in
        "grey" | "GREY")        echo -e ${auto_print_newline} "\033[90m$2 \033[00m" ;;
        "red" | "RED")          echo -e ${auto_print_newline} "\033[91m$2 \033[00m" ;;
        "green" | "GREEN")      echo -e ${auto_print_newline} "\033[92m$2 \033[00m" ;;
        "yellow" | "YELLOW")    echo -e ${auto_print_newline} "\033[93m$2 \033[00m" ;;
        "blue" | "BLUE")        echo -e ${auto_print_newline} "\033[94m$2 \033[00m" ;;
        "purple" | "PURPLE")    echo -e ${auto_print_newline} "\033[95m$2 \033[00m" ;;
        "cyan" | "CYAN")        echo -e ${auto_print_newline} "\033[96m$2 \033[00m" ;;
        "white" | "WHITE")      echo -e ${auto_print_newline} "\033[96m$2 \033[00m" ;;
        *   )               echo -e ${auto_print_newline} "\033[96m$2 \033[00m" ;;
    esac


}

# Examples
# print_colored 'red' 'my message'
# print_colored 'red' 'my message\n\n' 'no'


# **********************************************************
#           MAIN PROGRAM START
# **********************************************************

prHeader '=' 
prtxtCentre "LinuxRay" 
prHeader '='
printf '\n\n\n'

print_colored "green" "Top Five Processes Eating Memory"
prHeaderLeftQuarter "-"
ps auxf | sort -nr -k 4 | head -5 | awk '{ print "MEM%: " $4  "| PID: " $2 " | CMD: " $11 $12 $13 }'  
echo

print_colored "green" "Top Five Processes Eating CPU"
prHeaderLeftQuarter "-"
ps auxf | sort -nr -k 3 | head -5 | awk '{ print "CPU%: " $3  "| PID: " $2 " | CMD: " $11 $12 $13 }'
echo

# kill any running processes pointing to deleted files
print_colored "green" "Running Processes attached to deleted files"
prHeaderLeftQuarter "-"
num_proc_del=$(lsof | grep -i deleted | wc -l)
print_colored "BLUE" "Found: ${num_proc_del}" "no"
lsof | grep -i deleted | tr -s [:space:] | cut -d ' ' -f 2 | xargs kill 
printf "[DELETED]"
echo
echo

exit 0

 

# Update cache and (maybe?) upgrade binaries
apt update 


logout

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
