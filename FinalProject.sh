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
    echo "----------------------------------------"
    echo " Open Ports and Detected Services"
    echo "----------------------------------------"
    echo "$SCAN_RESULTS" | grep "open"
    echo ""
}

query_nvd() {
    local product="$1"
    local version="$2"
    local results_limit=3

    echo ""
    echo "Querying NVD for vulnerabilities in: $product $version..."

    # URL encode spaces
    local search_query
    search_query=$(echo "$product $version" | sed 's/ /%20/g')

    local nvd_api_url="https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${search_query}&resultsPerPage=${results_limit}"
    local vulnerabilities_json
    vulnerabilities_json=$(curl -s "$nvd_api_url")

    # Defensive checks
    if [[ -z "$vulnerabilities_json" ]]; then
        echo "  [!] Error: Failed to fetch data from NVD."
        return
    fi
    if echo "$vulnerabilities_json" | jq -e '.message' > /dev/null; then
        echo "  [!] NVD API Error: $(echo "$vulnerabilities_json" | jq -r '.message')"
        return
    fi
    if ! echo "$vulnerabilities_json" | jq -e '.vulnerabilities[0]' > /dev/null; then
        echo "  [+] No vulnerabilities found in NVD for this keyword search."
        return
    fi

    # Parse and format
    echo "$vulnerabilities_json" | jq -r \
        '.vulnerabilities[] |
        "  CVE ID: \(.cve.id)\n  Description: \((.cve.descriptions[] | select(.lang=="en")).value | gsub("\n"; " "))\n  Severity: \(.cve.metrics.cvssMetricV31[0].cvssData.baseSeverity // .cve.metrics.cvssMetricV2[0].cvssData.baseSeverity // "N/A")\n---"'
}

write_vulns_section() {
    echo "----------------------------------------"
    echo " Potential Vulnerabilities Identified"
    echo "----------------------------------------"

    # Strategy A: NSE "VULNERABLE" keyword
    echo "--- NSE Script Findings ---"
    echo "$SCAN_RESULTS" | grep "VULNERABLE" || echo "No 'VULNERABLE' flags found by NSE scripts."
    echo ""

    # Strategy B: Version parsing + NVD query
    echo "--- Service Version Analysis (with NVD lookups) ---"

    # Extract lines with open ports and service versions
    echo "$SCAN_RESULTS" | grep "open" | while read -r line; do
        # Example: "22/tcp open  ssh    OpenSSH 7.6p1 Ubuntu 4ubuntu0.7"
        service_info=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//')

        # Separate product name and version
        product_name=$(echo "$service_info" | awk '{print $1,$2}')
        product_version=$(echo "$service_info" | grep -oE '[0-9]+(\.[0-9]+)*([a-z0-9]*)')

        if [[ -n "$product_name" && -n "$product_version" ]]; then
            echo "[i] Found service: $product_name $product_version"
            query_nvd "$product_name" "$product_version"
        fi
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
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <target_ip_or_hostname>" >&2
        exit 1
    fi

    local target="$1"
    local REPORT_FILE="network_scan_report.txt"

    echo "[*] Running nmap scan with vulnerability scripts... this may take a while."
    SCAN_RESULTS=$(nmap -sV --script vuln "$target")

    write_header "$target" > "$REPORT_FILE"
    write_ports_section >> "$REPORT_FILE"
    write_vulns_section >> "$REPORT_FILE"
    write_recs_section >> "$REPORT_FILE"
    write_footer >> "$REPORT_FILE"

    echo "[*] Report saved to $REPORT_FILE"
}

main "$@"
