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


# **********************************************************
#           MAIN PROGRAM START
# **********************************************************

# Heading
prHeader '=' 
prtxtCentre "LinuxRay" 
prHeader '='
printf '\n\n\n'


### PERFORMANCE
prHeaderLeftQuarter "="
print_colored "cyan" "PERFORMANCE"
prHeaderLeftQuarter "="
echo

# RAM
print_colored "green" "Top Five Processes Eating Memory"
prHeaderLeftQuarter "-"
ps auxf | sort -nr -k 4 | head -5 | awk '{ print "MEM%: " $4  " | PID: " $2 " | CMD: " $11 $12 $13 }'  
echo
echo

# CPU
print_colored "green" "Top Five Processes Eating CPU"
prHeaderLeftQuarter "-"
ps auxf | sort -nr -k 3 | head -5 | awk '{ print "CPU%: " $3  " | PID: " $2 " | CMD: " $11 $12 $13 }'
echo
echo

# Count/Kill any running processes pointing to deleted files
print_colored "green" "Running Processes attached to deleted files"
prHeaderLeftQuarter "-"
num_proc_del=$(lsof 2>/dev/null | grep -i deleted | wc -l)
print_colored "BLUE" "Found: ${num_proc_del}" "no"
lsof 2>/dev/null | grep -i deleted | tr -s [:space:] | cut -d ' ' -f 2 | xargs kill &> /dev/null
printf "[CLEANED]\n"
echo
echo

# see which process tkes the longest to start om boot
print_colored "green" "Top Five Processes that take the longest to load on boot"
prHeaderLeftQuarter "-"
systemd-analyze blame 2> /dev/null | head -5
echo
echo

# Zombie processes
zomb_count=$(ps aux | awk '/Z/ { pid=$2;state=$8;cmd=$11; if(state=="Z")print pid,cmd }' | wc -l)
print_colored "green" "Zombie Processes (${zomb_count} Total)"
prHeaderLeftQuarter "-"
ps aux | awk '/Z/ { pid=$2;state=$8;cmd=$11; if(state=="Z")print pid,cmd }' | head
echo
echo


### USAGE AND FILESYSTEM
prHeaderLeftQuarter "="
print_colored "cyan" "USAGE AND FILESYSTEM"
prHeaderLeftQuarter "="
echo
echo

# Drive Usage
print_colored "green" "Percent Used per Drive"
prHeaderLeftQuarter "-"
df -h | grep -Ev 'tmpfs|Filesystem|none' | awk '{ print $1 " => " $5 }'
echo
echo


# critical disk usage (show top three large files)
print_colored "green" "Top 3 Largest Folders"
prHeaderLeftQuarter "-"

print_colored "BLUE" "Starting at /"
sudo du /* -hd0 2>/dev/null | sort -rhk1 | head -3
echo

print_colored "BLUE" "Starting at /home/"
sudo du /home/* -hd0 2>/dev/null | sort -rhk1 | head -3
echo

print_colored "BLUE" "Starting at /var/"
sudo du /var/* -hd0 2>/dev/null | sort -rhk1 | head -3
echo
echo


# Dangling link cleanup
print_colored "green" "Finding/Cleaning any dangling softlinks"
prHeaderLeftQuarter "-"
printf "Searching... "
sudo find / -maxdepth 5  -xtype l 2>/dev/null -exec rm {} \;
echo "Cleaned Up! (searched 5 levels deep from root)"
echo
echo



### NETWORK AND SECURITY
prHeaderLeftQuarter "="
print_colored "cyan" "NETWORK AND SECURITY"
prHeaderLeftQuarter "="
echo

# Get Open Ports
print_colored "green" "Listening Ports"
prHeaderLeftQuarter "-"

using_netstat=$({ netstat --version &> /dev/null && echo 1 ; } || echo 0)

if [[ using_netstat == 1 ]]
then
  sudo netstat -tulpn | grep LISTEN | awk '{ print $7 }' | sed -E 's/\/.*//'
else
  sudo ss -tulpn | awk '{ print $5 }' | grep -Ev '^127|Local' | sed -E 's/^.*\://' | sort | uniq
fi
echo
echo


# Security
print_colored "green" "Security Checks"
prHeaderLeftQuarter "-"

#  SSH see if root login is enabled
print_colored "blue" "[SSH] " "no"
printf "PermitRootLogin: \t\t\t"
root_login_enabled=$(grep -E '^PermitRootLogin|^\s+PermitRootLogin' /etc/ssh/sshd_config | sort -rk1 | tail -1 | awk '{ print $2 }' | xargs)

if [[ "${root_login_enabled,,}" == 'yes' ]]
then
  print_colored "red" "Enabled" "no"
  print_colored "yellow" "[WARNING]" "no"
  printf "Please consider disabling this feature!"
else
  print_colored "green" "Disabled"
fi


# SSH see if password auth is accepted
print_colored "blue" "[SSH] " "no"
printf "PasswordAuthentication: \t\t\t"
pass_login_enabled=$(grep -E '^PasswordAuthentication|^\s+PasswordAuthentication' /etc/ssh/sshd_config | sort -rk1 | tail -1 | awk '{ print $2 }' | xargs)

if [[ "${pass_login_enabled,,}" == 'yes' ]]
then
  print_colored "red" "Enabled" "no"
  print_colored "yellow" "[WARNING]" "no"
  printf "Please consider disabling this feature!"
else
  print_colored "green" "Disabled"
fi


# Reboot Hotkey
print_colored "blue" "[SSH] " "no"
printf "SSH Remote Reboot Hotkey (CTRL+ALT+DEL): "
if [[ -e /etc/systemd/system/ctrl-alt-del.target ]] 
then
  print_colored "green" "Disabled" "no"
else
  print_colored "red" "Enabled" "no"
  sudo systemctl mask ctrl-alt-del.target &> /dev/null
  print_colored "green" "=> Fixed [Disabled]" "no"
fi
echo


# Vulvertable to fork bomb?
  # Could use ulimit to fix - but editing limit.conf as ulimit is temporary (session-based)
if [[ -e /etc/security/limits.conf ]]
then
  # Checking root
  print_colored "blue" "[LMT] " "no"
  printf "Vulnerable to Fork Bomb (Root): \t\t"

  num_root=$(grep -E '(^root)|(^\s+root)' /etc/security/limits.conf | grep nproc | tail -1 | awk '{ print $4 }')

  if [[ "${num_root}" -gt 0 ]]
  then
    print_colored "green" "NO " "no"
    printf "\t[Current nproc root Limit : ${num_root}]"
  else
    print_colored "red" "YES " "no"
    sudo bash -c "echo -e 'root\t\thard\tnproc\t\t30' >> /etc/security/limits.conf"
    print_colored "green" "=> FIXED " "no"
  fi
  echo
  
  # Checking all
  print_colored "blue" "[LMT] " "no"
  printf "Vulnerable to Fork Bomb (all):  \t\t"

  num_all=$(grep -E '(^\*)|(^\s+\*)' /etc/security/limits.conf | grep nproc | tail -1 | awk '{ print $4 }')

  if [[ "${num_all}" -gt 0 ]]
  then
    print_colored "green" "NO " "no"
    printf "\t[Current nproc all Limit : ${num_all}]"
  else
    print_colored "red" "YES " "no"
    sudo bash -c "echo -e '*\t\thard\tnproc\t\t30' >> /etc/security/limits.conf"
    print_colored "green" "=> FIXED " "no"
  fi
  echo
  
  

fi


# Last password change
print_colored "blue" "[PAS] " "no"
pass_change=$(chage -l $(whoami) | grep 'Last password change' | cut -d':' -f2)
printf "Last Password Change [$(whoami)]:  ${pass_change}"

echo
echo
echo

# Fail SSH logins
print_colored "green" "Failed SSH Logins (most recent 10)"
prHeaderLeftQuarter "-"

# Debian
if [[ -e /var/log/auth.log ]]
then
  sudo grep -E 'Failed\spassword|Invalid\suser' /var/log/auth.log | tail
# Redhat
elif [[ -e /var/log/auth.log ]]
then
  sudo grep -E 'Failed\spassword|Invalid\suser' /var/log/secure.log | tail
else
# System D
  sudo journalctl _COMM=sshd | grep -E 'Failed\spassword|Invalid\suser' | tail
fi

# Make a systemd service of itself


echo
echo

# Heading
prHeader '=' 
prtxtCentre "LinuxRay - END" 
prHeader '='
printf '\n\n\n'


exit 0

 

#######  POSSIBLE TODOS ########

# old file archiver
# integrity checker
# load average (lscpu to see num cores)
# Security checks
  # mysql --version to see if mysql/maris db is enabled and port is open on 3306.
  # check fstab for deice name instead of UUIDs
  # Listening on standard SSH port
  # w or who to see idle users for long time
  # c option too compress large text files (any greater than 100mb) 
