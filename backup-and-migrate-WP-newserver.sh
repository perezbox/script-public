#!/bin/bash
# Created by: Tony Perez
# Version 1.0
#####################################################
##################################################### 
# Description:
# This script was crated to automate the work involved with migrating a site from one server to another.
# This script assumes the following:
# - New LAMP stack is configured;
# - WordPress has been configured according to the scripts in my repo;
# - Looks for the same naming convention and site structure;
#
# This script will do the following:
# - Depends on the naming convention my other sripts introduce (e.g., Domain becomes a critical piece of the naming convention)
# - Will tar wp-content for the existing site, it will not migrate core directories (assumes you're starting new)
# - Will create a backup of the old database
# - Will push the wp-content tar files to the new server (requires you know the server access information)
# - Will create a backup of the old database
# - Will push the datase sql file to the new server
# - Will untar the old files and place them in the new wp-content folder
# - Will upload the sql file into the new DB
# - Will create the DB user / Pass to match the old DB configuration (this is necessary when doing migrations so that the information can be accessed, that or you have to grant permissions to an existing user. This script will assume the user will create the user / pass to match.)
#

#on the server you are decommissioning

echo "This script is going to crate a backup of your site, and associated DB, and push to a remote server."
echo "It assumes you are using my naming convention (e.g., /var/www/[domainname.com]"
echo " "
echo "It will require you have credentials for the remote server and database, and the current server."
echo " "
echo "Run on the production server. Altough, now that I think about it I should have done it the opposite direction.."
echo " "

echo "Enter domain you are moving:"

read domain

echo "Enter remote server IP you are moving domain to:"

read serverip

echo "Enter the admin user for the remote server:"

read rootuser

tar -czvf $domain.tar.gz -C /var/www/$domain/wp-content .

scp $domain.tar.gz $rootuser@$serverip:/var/www/$domain/wp-content/

ssh $rootuser@$serverip "tar -xzvf /var/www/$domain/wp-content/$domain.tar.gz -C /var/www/$domain/wp-content"

echo "Enter the username for the DB owner that is being migrated:"

read dbuser

echo "Enter name of DB to be migrated (i.e., database must currently exist):"

read dbname

echo "Creating dump of the database on this server.."
mysqldump --user=$dbuser -p --lock-tables --databases $dbname > /var/www/$domain/wp-content/$domain.sql

echo "Pushing .sql backup to new server..."

scp /var/www/$domain/wp-content/$domain.sql $rootuser@$serverip:/var/www/$domain/wp-content/ 

echo "Enter admin user for the DB on remote server (e.g., root):"

read dbroot

echo "Creating new $dbname database on remote server..."
ssh $rootuser@$serverip "mysql --user="$dbroot" -p -e \"create database $dbname;\""


echo "The $dbname database was created..."

echo "Creating $dbuser user in $dbname database on remote server.."

echo "Enter the password for the $dbuser:"

read $dbuserpass

ssh $rootuser@$serverip "mysql --user="$dbroot" -p --execute=\"create user '$dbuser'@'localhost' identified by '$dbuserpass';\""

echo "Giving $dbuser privileges to $dbname database..."
ssh $rootuser@$serverip "mysql --user="$dbroot" -p --execute=\"grant all privileges on $dbname.* to $dbuser@localhost ;\"" 

#ssh $rootuser@$serverip "mysql -u dbroot -p$dbrootpass $dbname < /var/www/$domain/wp-content/$domain.sql"
