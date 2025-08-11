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

    # Show open ports only from scan results
    echo "$SCAN_RESULTS" | grep "open"
    echo ""
}

write_vulns_section() {
    echo "----------------------------------------"
    echo " Potential Vulnerabilities Identified"
    echo "----------------------------------------"

    # Strategy A: High-confidence matches for "VULNERABLE"
    echo "--- NSE Script Findings ---"
    echo "$SCAN_RESULTS" | grep "VULNERABLE" || echo "No 'VULNERABLE' flags found by NSE scripts."
    echo ""

    # Strategy B: Manual version-based checks
    echo "--- Analyzing Service Versions ---"
    echo "$SCAN_RESULTS" | while read -r line; do
        case "$line" in
            *"vsftpd 2.3.4"*)
                echo "[!!] VULNERABILITY DETECTED: vsftpd 2.3.4 contains a known critical backdoor."
                ;;
            *"Apache httpd 2.4.49"*)
                echo "[!!] VULNERABILITY DETECTED: Apache 2.4.49 vulnerable to path traversal (CVE-2021-41773)."
                ;;
            *"OpenSSH 7.2p2"*)
                echo "[!!] VULNERABILITY DETECTED: OpenSSH 7.2p2 contains multiple security issues."
                ;;
        esac
    done
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

    echo "[*] Running nmap scan with vulnerability scripts... this may take a while."
    # Run scan once and store results for reuse
    SCAN_RESULTS=$(nmap -sV --script vuln "$target")

    # Generate report
    write_header "$target" > "$REPORT_FILE"
    write_ports_section "$target" >> "$REPORT_FILE"
    write_vulns_section >> "$REPORT_FILE"
    write_recs_section >> "$REPORT_FILE"
    write_footer >> "$REPORT_FILE"

    echo "[*] Report saved to $REPORT_FILE"
}

# ----------- Run Script -----------
main "$@"
