#!/bin/bash
CACHE_FILE="/tmp/zabbix.rabbitmq-discovery.cache"

printf "" > $CACHE_FILE
printf "{" >> $CACHE_FILE
printf "\"data\":[" >> $CACHE_FILE

sudo /usr/sbin/rabbitmqctl -q list_vhosts | while read vhost
 do
  vhost_t=$(echo $vhost| sed 's!/!\\/!g')
  #vhost
  sudo /usr/sbin/rabbitmqctl -q list_queues -p $vhost | awk '$1=$1' | sed 's/ [0-9]*$//' | while read queue
  do
     #queue
     queue_t=$(echo $queue| sed 's!/!\\/!g')
     printf "{" >> $CACHE_FILE
     printf "\"{#VHOSTNAME}\":\"$vhost\", \"{#QUEUENAME}\":\"$queue_t\"" >> $CACHE_FILE
     printf "}," >> $CACHE_FILE
  done
 done

output=`sed 's/,$//' $CACHE_FILE`
echo -n $output > $CACHE_FILE

printf "]" >> $CACHE_FILE
printf "}" >> $CACHE_FILE

echo `cat $CACHE_FILE`

