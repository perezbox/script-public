#!/bin/sh
  
#DEFINE CONSTANTS
IPT="/sbin/iptables"
IP6="/sbin/ip6tables"
IPS=`curl --max-time 5 -s "enter_web_hook" | grep "success" | cut -d ":" -f 3 | cut -d "," -f 1`
#HM="47.145.21.43"
#OF="47.180.59.90"
#JB="jumpbox"

#REMOVE IPT TEMP FILE IF IT EXISTS
rm -f /root/ipt1

#Write Existing IPTables to External File
$IPT -nL > /root/ipt1

#Flush the existing IP Tables Rules to avoid redundancy
$IPT -F

#Check if the IP in the server key exist in IP Tables
#If it doesn't, add it
if [ ! "x$IPS" = "x" ]; then
    grep "ACCEPT" /root/ipt1 |grep "$IPS" >/dev/null 2>&1
    if [ ! $? = 0 ]; then
        $IPT -I INPUT --source "$IPS" -p tcp -j ACCEPT -m comment --comment "Dynamic IPAuth: $IPS"
    fi
fi

#remove the working file IPT1
rm -f /root/ipt1

# LOG RELOAD > Log change 
MDATE=`date +"%Y-%m-%d %H:%M:%S"`
/bin/echo "$MDATE DEBUG: Reloading firewall" >> /var/log/fw.log

# ALLOW SSH
#$IPT -A INPUT --source "$JB" -p tcp --dport 22 -j ACCEPT -m comment --comment "JumpBox"

# DENY
$IPT -A INPUT -p tcp --dport 22 -j DROP
$IPT -A INPUT -p tcp --dport 25 -j DROP
$IPT -A INPUT -i eth0 -p tcp --dport 3306 -j DROP
$IP6 -I INPUT -j DROP
