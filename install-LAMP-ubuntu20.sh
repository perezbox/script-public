#!/bin/bash
# Created by: Tony Perez
# Version 1.0
#####################################################
##################################################### 
# Description:
# This script was designed to streamline the manual configuration of LAMP on Ubuntu.
# This script will do the following:
# - check for updates and apply them;
# - install all the necessary dev libraries you'll need on a LAMP stack;
# - install apache;
# - install certbot;
# - configure the system firewall to allow HTTP/HTTPS;
# - ensure appropriate modules are enabled for SSL;
# - install PHP and all the required dependencies and libraries for WordPress, and most common CMS applications;
# - install MariaDB as the system database;
# - will end by asking you to configure the DB securely to ensure the step is not missed;
######################################################
#
# Created to streamline my own deployment and confiugraion of servers.
#Automating the process reduces human error, and improves the overall maintainabilty of my digital assets.

#Configuring a web server on Ubuntu 20.04 LTS

echo "What would you like to call this server (setting hostname)?"

read hostname

echo "Settings hostname to system..."
hostnamectl set-hostname $hostname
s -i "s/localhost/$hostname/g" "/etc/hostname"

echo "Preparing server environment.."
echo "Checking for updates..."
apt update

echo "Applying available updates..."
apt -y upgrade

echo "Installing dev libraries..."

apt -y install gcc make libevent-dev zlib1g-dev  libssl-dev libpcre2-dev wget tar net-tools

echo "Installing Apache daemon..."
apt -y install apache2 certbot python3-certbot-apache

echo "Updating Firewall to allow APACHE"
ufw allow 'Apache Full'

echo "Enabling rewrite module"
a2enmod rewrite

echo "Enabling the SSL Module to all for HTTPS connections"
a2enmod ssl
systemctl restart apache2
ufw allow https

echo "Installing php daemon..."
apt -y install php libapache2-mod-php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-xmlrpc php-intl php-gd

echo "Installing mariadb daemon..."
apt -y install mariadb-server

echo "Please configure DB securely.."
mysql_secure_installation
