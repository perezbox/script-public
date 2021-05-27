#!/bin/bash
# Monitor state of OSSEC agents
# Check all Core OSSEC Daemons are running
# If daemons are not running -> Recrod in a new log and notify via Slack Integration

#/var/ossec/bin/ossec-control status | grep “not running…” >/dev/null 2>&1

echo "This script is designed to be used with a cron job."
echo "It checks to make sure that the OSSEC daemons are running. If not, they send a notification to your slack."
echo "This script is designed to run with the configuration script, if you want to run manually remove comments on the user inputs."

#echo "Enter Slack Channel:"

#read channel

#echo "Enter alert title:"

#read alerttitle

#echo "Enter full slack webhook:"

#read slackhook

for i in ossec-execd ossec-remoted ossec-analysisd ossec-syscheckd ossec-monitord ossec-logcollector ossec-integratord; 
	 
do ps auwx | grep -v grep | grep $i >/dev/null 2>&1 ; 

if [ $? = 0 ]; 
			       
then 
echo `date "+%Y-%m-%d %H:%M "`"$i Running...";
					          

else
	
echo `date "+%Y-%m-%d %H:%M "`"$i not running..."; >> /root/documents/logs/ossecm/ossecm-monitoring.log
curl -X POST --data-urlencode "payload={\"channel\": \"#$channel\", \"username\": \"$ORG OSSECM $date:\", \"text\": \"$alerttitle: $i Daemons disabled. Remediation required.\", \"icon_emoji\": \":ghost:\"}" $slackhook

fi;
done
