#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
END='\033[0m'

cwd=$(pwd)

mkdir -p ~/tools
cd ~/tools

if [[ ! -d ~/tools/LinkFinder ]]
then
        git clone https://github.com/dark-warlord14/LinkFinder
else
        printf "${YELLOW}[!]${GREEN} LinkFinder already present in tools folder...!${END}\n\n"
fi

# check for in which (docker/Main_Host) script is running 
# If INODE_NUM is 2 then it is running on Main Host otherwise
# it is physical machine 
INODE_NUM=`ls -ali / | sed '2!d' |awk {'print $1'}`
if [ $INODE_NUM == '2' ]
then
    #UbuntuInstall
    sudo apt install wget -y
    cd LinkFinder
    sudo pip3 install -r requirements.txt
    sudo python3 setup.py install
    pip3 install jsbeautifier
else
    # DockerInstall 
    apt install wget -y
    cd LinkFinder
    pip3 install -r requirements.txt
    python3 setup.py install
    pip3 install jsbeautifier
fi



echo "alias jsscanner='$cwd/script.sh'" >> ~/.bashrc

. ~/.bashrc

echo -e "\n${YELLOW}[*]${GREEN} Installation Completed!${END}"
echo -e "${YELLOW}[!]${GREEN} Run Command ${CYAN}'source ~/.bashrc'${END}"
