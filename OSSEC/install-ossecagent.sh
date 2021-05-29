#!/bin/bash
# Created by: Tony Perez
# Version 1.0
#####################################################
##################################################### 
# Description:
# This script will configure an OSSEC Agent. It is designed to work with an OSSEC manager.
# This script will:
# - Check for dependencies based on OS type
# - Will create appropriate folders, default directory is /root
# - This uses the Daniel's OSSEC build
# - This script will install OSSEC using preload variables.
# - Will ask you to define the Manager before doing the install.
# - All variables are created in the install directory ../etc/preloaded-vars.conf
# - This will not start OSSEC, you have to start manually once configured.
#

echo "Hi, this script is going to install the OSSEC product with an Agent configuration.."
echo "Please be sure to watch for the prompt to enter the Manager IP."
echo "All other settings are set in preloaded-vars.conf to streamline the deployment."

#Begin installation of OSSEC: https://dcid.me/texts/my-ossec-setup-manual.html
RED='\033[0;31m'
NC='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)

#Install dependencies first

if [ "x$1" = "xcentos" ] ; then
    echo "You have selected CentOS"
    echo "Installing CentOS dependencies"
    sudo yum -y install gcc make libc-dev wget
    echo "Done with CentOS dependencies."

elif [ "x$1" = "xubuntu" ] ; then
    echo "You have selected Ubuntu"
    echo "Intalling Ubuntu dependencies"
    sudo apt install -y gcc make libevent-dev zlib1g-dev  libssl-dev libpcre2-dev wget unzip tar
    echo "Done with Ubuntu dependencies."
elif [ "x$1" = "xdebian" ] ; then
    echo "You have selected Debian"
    echo "Installing Debian dependencies"
    sudo apt-get update
    sudo apt-get install -y build-essential inotify-tools ntp
    sudo systemctl start ntp
    echo "Debian doesn't have IPTables..will install"
    sudo apt-get install -y iptables-persistent
    sudo systemctl restart netfilter-persistent
    echo "Done with Debian dependencies."
elif [ "x$1" = "xfederoa" ] ; then
    echo "You have selected Federoa"
    echo "Installing Fedora dependencies"
    sudo yum install -y bind-utils gcc make inotify-tools
    echo "Done with Fedora dependencies."
else 
    echo " "
    echo "Please pass one of the following options into the script:" 
    echo " "
    echo -e "       Run the following command: ${RED}$0 centos${NC}"
    echo -e "       Run the following command: ${RED}$0 ubuntu${NC}"
    echo -e "       Run the following command: ${RED}$0 debian${NC}"
    echo -e "       Run the following command: ${RED}$0 fedora${NC}"
    exit 1
fi

echo "Creating new Downloads directory in root"

cd /root/
mkdir /root/Downloads
cd /root/Downloads

PWD="/root/Downloads"

echo "New Downloads directory created and set"

echo "Downloading OSSEC installation"

wget https://github.com/dcid/ossec-hids/archive/refs/heads/master.zip

echo "Decrypting installation into Downloads folder"

unzip master.zip

echo "Switching directories to the new decrypted installation"

downloaddir="/root/Downloads/ossec-hids-master"

#Setting Default OSSEC installation settings

echo "Adding default OSSEC configurations values:"

echo "Enter manager IP:"

read managerIP

echo "Set language to English..."
echo "USER_LANGUAGE="en"" > $downloaddir/etc/preloaded-vars.conf 

echo "Disabled confirmation messages..."
echo "USER_NO_STOP="y"" >> $downloaddir/etc/preloaded-vars.conf 

echo "User deployment as an AGENT install.."
echo "USER_INSTALL_TYPE="agent"" >> $downloaddir/etc/preloaded-vars.conf 

echo "Set the OSSEC server.."
echo "USER_AGENT_SERVER_IP="$managerIP"" >> $downloaddir/etc/preloaded-vars.conf

echo "Set default location as /var/log/ossec..."
echo "USER_DIR="/var/ossec"" >> $downloaddir/etc/preloaded-vars.conf

echo "Enabled Active Response..."
echo "USER_ENABLE_ACTIVE_RESPONSE="y"" >> $downloaddir/etc/preloaded-vars.conf 

echo "Enabled system checks..."
echo "USER_ENABLE_SYSCHECK="y"" >> $downloaddir/etc/preloaded-vars.conf

echo "Enabled rootcheck..."
echo "USER_ENABLE_ROOTCHECK="y"" >> $downloaddir/etc/preloaded-vars.conf

echo "Disabled email notifications..."
echo "USER_ENABLE_EMAIL="n"" >> $downloaddir/etc/preloaded-vars.conf 

echo "Enabled Firewall Response... "
echo USER_ENABLE_FIREWALL_RESPONSE="y" >> etc/preloaded-vars.conf


echo "Done adding defaults..."

echo "Begin the OSSEC installation..."

cd $downloaddir

./install.sh

echo "OSSEC installed successfully, begin manual configuration..."

#Cleaning up mess

echo "Cleaning up mess.."

rm /root/Downloads/master.zip

echo "Installation is complete.."

