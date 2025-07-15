# NTS370_NetworkScanner
This Bash script automates the process of generating a basic network security report for a specified target IP address or hostname. It utilizes `nmap` to scan for open ports and running services, then structures the findings into a human-readable report file.

##What the Script Does

- Accepts a single command-line argument (target IP address or hostname)
- Validates that exactly one argument is provided
- Performs a live network scan using `nmap -sV` to detect:
  - Open ports
  - Services running on those ports
  - Service versions (if available)
- Filters the scan output to include only open ports
- Creates a structured report saved to `network_scan_report.txt` including:
  - A header with the target information
  - Detected open ports and services
  - Placeholder sections for potential vulnerabilities and recommended remediation steps
  - A footer with the date the scan was generated

##Requirements

- Bash (Linux, macOS, or WSL on Windows)
- `nmap` installed on your system

###Install `nmap` (if not already installed)

####Debian/Ubuntu:
```bash
sudo apt install nmap
