#Network Vulnerability Scanner Script

This Bash script automates the process of scanning a target host for open ports, services, and potential vulnerabilities.  
It uses `nmap` for detection and integrates with the **National Vulnerability Database (NVD) API** to cross-reference service versions against known CVEs.  
The script outputs a structured, human-readable report.

---

##Features

- **Command-line input**: Accepts a single target IP or hostname as an argument.
- **Input validation**: Ensures exactly one argument is provided, otherwise shows usage instructions.
- **Structured report generation**: Saves all results to `network_scan_report.txt` with clearly defined sections:
  - Header (target details, timestamp)
  - Open ports and services (via `nmap -sV`)
  - Potential vulnerabilities (via NSE + NVD lookups)
  - Recommendations
  - Footer (end of report)
- **Nmap Scanning**:
  - Service and version detection (`-sV`)
  - Vulnerability script execution (`--script vuln`)
  - OS and additional details (optional with `-A`)
- **Vulnerability Analysis**:
  - **Strategy A**: Highlights NSE script results flagged as `VULNERABLE`.
  - **Strategy B**: Extracts service names and versions, then queries the **NVD API** with `curl` and `jq`.
  - Displays CVE ID, description, and severity score for known issues.
- **Extensible**: New checks or additional parsing logic can be added easily.

---

##Requirements

Install the following packages on your system:

```bash
sudo apt update
sudo apt install nmap jq curl -y
