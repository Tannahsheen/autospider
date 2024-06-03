#!/bin/bash

sudo apt-get update -y

sudo apt-get install -y crackmapexec

sudo apt-get install -y smbclient

python3 -m pip install --user pipx
python3 -m pipx ensurepath

pipx install git+https://github.com/blacklanternsecurity/MANSPIDER

cd "$(dirname "$0")"

chmod +x autospider.sh autospider2.sh

echo "All prerequisites have been installed and scripts are now executable."
