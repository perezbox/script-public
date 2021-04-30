#!/bin/bash
# Created by: Tony Perez
# Version 1.0
#####################################################
##################################################### 
# Description:
# This script was designed to streamline the manual configuration of WordPress.
# This script will do the following: 
# - Create a new directory in /var/www/ for your domain;
# - Directory will be labeled according to the domain you are setting up
#  e.g., perezbox.com would be /var/www/perezbox.com
# - Will download WordPress and deploy it at the root of your site directory;
# - Will create a new vhosts file for the domain, using the domain name to standardize syntax and remove errors;
# - Will verify the config is free of errors, and restart Apache
# - Will automatically create a Database, Username and Password for your site;
# - Will populate your WordPress wp-config configuration file with all the appropraite settings;
# - Will print to the screen all the unique values so that you can save it in your inventory documentation;
######################################################
#
# Created to streamline my own deployment and confiugraion of sites. Automating the process reduces human error, and improves the overall maintainabilty of my digital assets.

#creating new web directory for the domain

echo "Pleae name the directory for your domain, followed by [enter]:"  

read directory 

echo "Creating $directory directory inside /var/www/" 

mkdir /var/www/$directory 

echo "Set working directory to /var/www/$directory"  

cd /var/www/$directory  

#downloading the latest wordpress 

echo "Downloading the latest WordPress installation" 

wget https://wordpress.org/latest.tar.gz   

tar -xzvf latest.tar.gz 

#moving WP to the root directory for the site
echo "Installing WordPress into /var/www/$directory"        

mv wordpress/* /var/www/$directory/    
rm -rf /var/www/$directory/latest.tar.gz 
rm -rf /var/www/$directory/wordpress  
ls -la /var/www/$directory/  
mv /var/www/$directory/wp-config-sample.php /var/www/$directory/wp-config.php  

#making sure the user and group are correct for directory
echo "Set user to Apache user and group" 

chown -R www-data:ww-data /var/www/$directory

#using a preset vhosts file to help reduce errors. this file has specific phrasing we use to update with the domain name
curl "https://raw.githubusercontent.com/perezbox/script-public/main/vhosts" > /etc/apache2/sites-available/$directory.conf

sed -i "s/your_domain/$directory/g" "/etc/apache2/sites-available/$directory.conf"

#enabling the domain vhosts file
echo "Enabling vhosts file with Apache" 
a2ensite $directory 

echo "Testing new vhosts syntax" 
apache2ctl configtest 

echo "Reloading Apache with new config file"
systemctl reload apache2 

#creating a new DB and pushing the values to wp-config programmaticallly
echo "Let's configure the DB and WP-CONFIG files..."
echo "Please enter the root password for your DB here:"
read ROOTPASS

DBNAME=db_$RANDOM
DBPASS=`openssl rand -base64 10`
DBUSER=user_$DBNAME

echo "New database is being created"
mysql -u root -p$ROOTPASS -e "create database $DBNAME;create user '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';grant all privileges on $DBNAME.* to $DBUSER@localhost "

DOMAINROOT="/var/www/$directory/"

echo "Let's configure wp-config to use these credentials..."

sed -i "s/database_name_here/$DBNAME/g" "$DOMAINROOT/wp-config.php"
sed -i "s/username_here/$DBUSER/g" "$DOMAINROOT/wp-config.php"
sed -i "s/password_here/$DBPASS/g" "$DOMAINROOT/wp-config.php"

sed -i '49,56d' $DOMAINROOT/wp-config.php

AUTHKEY=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w AUTH_KEY`
SAUTHKEY=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w SECURE_AUTH_KEY`
LOGGEDKEY=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w LOGGED_IN_KEY`
NONCKEY=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w NONCE_KEY`
AUTHSALT=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w AUTH_SALT`
SAUTHSALT=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w SECURE_AUTH_SALT`
LOGGEDSALT=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w LOGGED_IN_SALT`
NONCESALT=`curl -s https://api.wordpress.org/secret-key/1.1/salt/ | grep -w NONCE_SALT`


sed -i "49 i $AUTHKEY" "$DOMAINROOT/wp-config.php"
sed -i "50 i $SAUTHKEY" "$DOMAINROOT/wp-config.php"
sed -i "51 i $LOGGEDKEY" "$DOMAINROOT/wp-config.php"
sed -i "52 i $NONCKEY" "$DOMAINROOT/wp-config.php"
sed -i "53 i $AUTHSALT" "$DOMAINROOT/wp-config.php"
sed -i "54 i $SAUTHSALT" "$DOMAINROOT/wp-config.php"
sed -i "55 i $LOGGEDSALT" "$DOMAINROOT/wp-config.php"
sed -i "56 i $NONCESALT" "$DOMAINROOT/wp-config.php"

echo " " 
echo "Ok, everything should be configured correctly. Please save the following values and check your new site:"
echo " " 
echo "Domain configured: $directory"
echo "Directory for site: $DOMAINROOT"
echo "DB Name: $DBNAME"
echo "DB User: $DBUSER"
echo "DB Password: $DBPASS"
