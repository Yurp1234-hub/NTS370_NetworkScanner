#!/bin/bash

# ----------- Functions -----------

write_header() {
    local target="$1"
    echo "=============================="
    echo " Network Security Scan Report"
    echo "=============================="
    echo ""
    echo "Target IP Address/Hostname: $target"
    echo ""
}

write_ports_section() {
    local target="$1"
    echo "----------------------------------------"
    echo " Open Ports and Detected Services"
    echo "----------------------------------------"
    
    # Run nmap with service detection, filter for open ports only
    nmap -sV "$target" | grep "open"
    
    echo ""
}

write_vulns_section() {
    echo "----------------------------------------"
    echo " Potential Vulnerabilities Identified"
    echo "----------------------------------------"
    echo "CVE-2023-XXXX - Outdated Web Server"
    echo "Default Credentials - FTP Server"
    echo "CVE-2022-YYYY - Unpatched SSH Daemon"
    echo ""
}

write_recs_section() {
    echo "----------------------------------------"
    echo " Recommendations for Remediation"
    echo "----------------------------------------"
    echo "- Update all software to the latest versions."
    echo "- Change default credentials immediately."
    echo "- Implement a firewall."
    echo ""
}

write_footer() {
    echo "=============================="
    echo " End of Report"
    echo "Generated on: $(date)"
    echo "=============================="
}

main() {
    # Input validation
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <target_ip_or_hostname>" >&2
        exit 1
    fi

    local target="$1"
    local REPORT_FILE="network_scan_report.txt"

    # Generate report
    write_header "$target" > "$REPORT_FILE"
    write_ports_section "$target" >> "$REPORT_FILE"
    write_vulns_section >> "$REPORT_FILE"
    write_recs_section >> "$REPORT_FILE"
    write_footer >> "$REPORT_FILE"
}

# ----------- Run Script -----------
main "$@"
