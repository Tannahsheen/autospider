# autospider
autospider, this is just a script to automate finding smb shares and spidering a little quicker. 

install:
sudo bash install_spider.sh

this should do everything you need. 

running:
make an input ip list that contains your ip ranges.

run autospider.sh
it will prompt you for your ip list. This utility should find all of your open smb shares and output them into a list. 

from here run autospider2.sh, when it prompts for an input file type spider-hosts.txt
this will begin spidering all SMB shares that it can access, downloading sensitive data. 
