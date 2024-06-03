#!/bin/bash

# Prompt for the input file containing IP ranges
read -p "Enter the path to the file containing IP ranges: " IP_FILE

# Check if the file exists
if [ ! -f "$IP_FILE" ]; then
    echo "File not found: $IP_FILE"
    exit 1
fi

OUTPUT_FILE="spider-hosts.txt"

> "$OUTPUT_FILE"

while IFS= read -r ip_range; do
    echo "Scanning $ip_range for accessible SMB shares..."
    crackmapexec smb $ip_range -u '' -p '' --shares | awk '/READ|WRITE/ && !/READONLY/ {print $2}' >> "$OUTPUT_FILE"
done < "$IP_FILE"


sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"
echo "Scan completed. Hosts with accessible SMB shares are listed in $OUTPUT_FILE"
