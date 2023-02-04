# LinuxRay
Handles system cleanup tasks and scans for violations of security best practices and performance detriments.

Usage: `bash LinuxRay.sh`

Run passively (reporting mode - no changes made)
Usage: `bash LinuxRay.sh -r`


### PERFORMANCE CHECKS
- Top Five Processes Eating Memory
- Top Five Processes Eating CPU
- Running Processes attached to deleted files
- Top Five Processes that take the longest to load on boot

### USAGE AND FILESYSTEM
- Percent Used per Drive
- Top 3 Largest Folders
- Finding dangling softlinks (showing top 5)

### NETWORK AND SECURITY
- Listening Ports
- [SSH] PermitRootLogin
- [SSH] PasswordAuthentication
- [SSH] SSH Remote Reboot Hotkey (CTRL+ALT+DEL)
- Vulnerable to Fork Bomb 
- Last password change
 
Note: Must run as a sudoer.
