# autospider

autospider, A Bash script to find and loot open SMB shares using crackmapexec and MANSPIDER.
 this is just a script to automate finding smb shares and spidering a little quicker. 



Install
```bash
git clone https://github.com/yourusername/autospider.git
cd autospider
sudo chmod +x install_autospider.sh
sudo bash install_autospider.sh
```

``` bash
./autospider.sh -i <ip_range_file> [-l <loot_dir>] [-e <extensions>] [-k <A|B|C|custom>]
```
-i: IP range file (required)
-l: Loot directory (default: ~/manspider_loot)
-e: File extensions (default: txt doc docx xls ...)
-k: Keywords: A (standard), B (banking), C (education), or custom
-h: Help
Examples
./autospider.sh -i ips.txt
./autospider.sh -i ips.txt -k B -l /tmp/loot
Output
Loot goes to the specified directory (or ~/manspider_loot).








License
MIT
