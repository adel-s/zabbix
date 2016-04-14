#!/bin/bash

# script for item type 'external script'
# file must be located at ExternalScripts=/etc/zabbix/externalscripts path at zabbix server

if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
 echo "Usage: vmware_datastore.sh url login passwd datastore_name metric"
 exit 1
fi

vmware_url=$1
vmware_ip=$(echo $vmware_url | sed -r 's/https\:\/\/(.*)\/(.*)/\1/')
vmware_login=$2
vmware_passwd=$3
datastore_name=$4
metric=$5

tmpfile="/tmp/zabbix.vmware_datastore.tmpfile.$vmware_ip.$datastore_name.$metric"

curl_timeout=1

#debug section
logfile="/var/log/zabbix-server/zabbix.vmware_datastore.$vmware_ip.$datastore_name.$metric.log"
echo `date "+%F %T "`"Script started" > $logfile
echo "vmware_url:$vmware_url" >> $logfile
echo "vmware_ip:$vmware_ip" >> $logfile
echo "vmware_login:$vmware_login" >> $logfile
echo "vmware_passwd:$vmware_passwd" >> $logfile
echo "datastore_name:$datastore_name" >> $logfile
echo "metric:$metric" >> $logfile

#get moid by datastore_name
curl -ks -o $tmpfile https://$vmware_login:$vmware_passwd@$vmware_ip/mob/?moid=ha-datacenter
sleep $curl_timeout
moid=$(cat $tmpfile | grep "$datastore_name"  | sed -r "s/(.*)>(.*)<\/a> \($datastore_name\)(.*)/\2/")

#debug section
echo "moid:$moid" >> $logfile

rm $tmpfile

curl -ks -o $tmpfile https://$vmware_login:$vmware_passwd@$vmware_ip/mob/?moid=$moid&doPath=summary
sleep $curl_timeout

case $metric in
        "capacity")
        output=$(cat $tmpfile | grep 'capacity'  | sed -r 's/(.*)<capacity>(.*)<\/capacity>(.*)/\2/')
        ;;

        "freespace")
        output=$(cat $tmpfile | grep 'freeSpace' | sed -r 's/(.*)<freeSpace>(.*)<\/freeSpace>(.*)/\2/')
        ;;

        "uncommitted")
        output=$(cat $tmpfile | grep 'uncommitted' | sed -r 's/(.*)<uncommitted>(.*)<\/uncommitted>(.*)/\2/')
        ;;

        *)
        echo "Error: unknown metric"
        ;;
esac

echo $output

#debug section
echo "output:$output" >> $logfile
echo `date "+%F %T "`"Done." >> $logfile

rm $tmpfile