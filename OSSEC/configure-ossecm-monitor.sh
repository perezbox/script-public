#!/bin/bash
# Created by: Tony Perez
# Version 1.0
#####################################################
#####################################################
# Description:
# This script was designed to configure a monitor to check the availability of teh OSSEC daemons on the Manager. 
# This scrip will do the following:
# - Create appropriate directories in the /root directory (e.g., monitoring-scripts and logs);
# - Will download the latest ossecm-daemon-monitor.sh that contains the logic to monitor the daemons;
# - Will create a local cronjob on the server to execute the monitoring script at your requested time interval;
# - Will populate all the appropriate Webhoak options (e.g., channel, username, webhook);
# - Will configure the monitoring script to do all the heavy lifting. 
######################################################
######################################################


echo "Creating new monitoring-scripts directory in /root"
echo "This is where we'll look for the file"
# Creating the apporpriate directories and log file
mkdir /root/monitoring-scripts
mkdir /root/monitoring-scripts/logs
touch /root/moniotring-scripts/logs/ossecm-monitoring.log 
echo " " 


echo "Download the monitoring script..."
echo "This script is being written to /root/monitoring-scripts/ossecm-daemon-monitor.sh"

# Downloading the script you'll need for the cronjob
curl "https://raw.githubusercontent.com/perezbox/script-public/main/ossecm-daemon-monitor.sh" > /root/monitoring-scripts/ossecm-daemon-monitor.sh
chmod +x /root/monitoring-scripts/ossecm-daemon-monitor.sh

# Creating the scheduler in crontab
echo "Let's create the cronjob (i.e., scheduler)"
echo " "
echo "How often do you want to check the daemons? (less than 59 minutes):"

read num 

#This is adding the cron job and veifying it doesn't already exist
(crontab -l 2>/dev/null | fgrep -v "*/$num *  *  *  * /root/monitoring-scripts/ossecm-daemon-monitor.sh"; echo "*/$num *  *  *  * /root/monitoring-scripts/ossecm-daemon-monitor.sh") | crontab -

# Setting all the variables in the monitoring script so that the notifications can be sent to Slack. 

echo "Now let's set the monitoring variables.."
echo " " 
echo "Enter username abbreviation (e.g., nocbot):"

read username

echo "Enter Slack Channel (the # is not required):"

read channelname


echo "Enter full slack webhook:"

read slackhookfull

echo "Enter title to include in alert (e.g., NOC OSSECM Alets will show as Perez OSSECM: Alert ....):"

read alerttitle

sed -i "s/replaceuser/$username/g" "/root/monitoring-scripts/ossecm-daemon-monitor.sh"
sed -i "s/replacechannel/$channelname/g" "/root/monitoring-scripts/ossecm-daemon-monitor.sh"
sed -i "s/replacetitle/$alerttitle/g" "/root/monitoring-scripts/ossecm-daemon-monitor.sh"
sed -i "s,replaceslackhook,$slackhookfull,g" "/root/monitoring-scripts/ossecm-daemon-monitor.sh"
