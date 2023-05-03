# LinuxRay
Handles system cleanup tasks and scans for violations of security best practices and performance detriments.
By default this runs in "Reporting mode" where no system changes are made and issues are only reported.

Usage: `bash LinuxRay.sh`


Running in "Fix Mode" allows changes to be made to the system.
Fixable issues are denoted below with "[F]"

Fix Mode: `bash LinuxRay.sh -r`


### PERFORMANCE CHECKS
- Top Five Processes Eating Memory
- Top Five Processes Eating CPU
- Running Processes attached to deleted files [F]
- Top Five Processes that take the longest to load on boot

### USAGE AND FILESYSTEM
- Percent Used per Drive
- Top 3 Largest Folders
- Finding dangling softlinks (showing top 5) [F]

### NETWORK AND SECURITY
- Listening Ports
- [SSH] PermitRootLogin [F]
- [SSH] PasswordAuthentication [F]
- [SSH] SSH Remote Reboot Hotkey (CTRL+ALT+DEL) [F]
- Vulnerable to Fork Bomb [F]
- Last password change
 
Note: Must run as a sudoer.

![Alt text](https://raw.githubusercontent.com/bobby-valenzuela/LinuxRay/main/demo01.png?raw=true "Demo 1")  

![Alt text](https://raw.githubusercontent.com/bobby-valenzuela/LinuxRay/main/demo02.png?raw=true "Demo 2")  

![Alt text](https://raw.githubusercontent.com/bobby-valenzuela/LinuxRay/main/demo03.png?raw=true "Demo 3")
