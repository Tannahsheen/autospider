#!/bin/bash

sudo apt-get update -y
#sudo apt-get install -y crackmapexec
sudo apt-get install -y smbclient
sudo apt install -y pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install git+https://github.com/Pennyw0rth/NetExec
pipx install git+https://github.com/blacklanternsecurity/MANSPIDER
cd "$(dirname "$0")"
chmod +x autospider.sh
echo "Installation complete. Run './autospider.sh -h' for usage."
