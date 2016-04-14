#!/bin/bash
USER="username"
PASSWD="password"
CACHE_TTL="55"
CACHE_FILE="/tmp/zabbix.rabbitmq.cache"
EXEC_TIMEOUT="1"
NOW_TIME=`date '+%s'`

if [[ -z "$1" || -z "$2" || -z "$3" ]]
then
  echo "Missing incoming values. Use: rabbitmq-stats.sh vhost queue metric"
  exit 1
fi

vhost=$1
queue=$2
vhost_t=$(echo $1| sed 's!/!\\/!g')
queue_t=$(echo $2| sed 's!/!\\/!g')
metric=$3


##### RUN #####
if [ -s "${CACHE_FILE}" ]; then
  CACHE_TIME=`stat -c"%Y" "${CACHE_FILE}"`
else
  CACHE_TIME=0
fi
DELTA_TIME=$((${NOW_TIME} - ${CACHE_TIME}))
#
if [ ${DELTA_TIME} -lt ${EXEC_TIMEOUT} ]; then
  sleep $((${EXEC_TIMEOUT} - ${DELTA_TIME}))
elif [ ${DELTA_TIME} -gt ${CACHE_TTL} ]; then
  echo "" >> "${CACHE_FILE}"
  DATACACHE=`sudo /usr/sbin/rabbitmqadmin -u$USER -p$PASSWD -f long -d 3 list queues | sed 's/^[ \t]*//' | sed '/^$/d' |sed 's/----------------/-/g' 2>&1`
  echo "${DATACACHE}" > "${CACHE_FILE}"
  chmod 640 "${CACHE_FILE}"
fi


if [[ $vhost != "none" ]]
then
    awk '/vhost: '$vhost_t'$/,/-----/' $CACHE_FILE | awk '/name: '"$queue_t"'$/,/-----/' | grep -P '^'$metric': ' | sed 's/'$metric': //'
else
    case $metric in
    "version")
    sudo /usr/sbin/rabbitmqctl status | awk '/{rabbit,\"RabbitMQ\",\"/,/\"}/' | awk -F "[,\"}]" '{print $6}'
    ;;
    "uptime")
    sudo /usr/sbin/rabbitmqctl status | awk '/{uptime,/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_total")
    sudo rabbitmqctl status | awk '/{total,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_connection")
    sudo rabbitmqctl status | awk '/{connection_procs,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_queue")
    sudo rabbitmqctl status | awk '/{queue_procs,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_plugins")
    sudo rabbitmqctl status | awk '/{plugins,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_other_proc")
    sudo rabbitmqctl status | awk '/{other_proc,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_mnesia")
    sudo rabbitmqctl status | awk '/{mnesia,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_mgmt_db")
    sudo rabbitmqctl status | awk '/{mgmt_db,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_msg_index")
    sudo rabbitmqctl status | awk '/{msg_index,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_other_ets")
    sudo rabbitmqctl status | awk '/{other_ets,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_binary")
    sudo rabbitmqctl status | awk '/{binary,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_code")
    sudo rabbitmqctl status | awk '/{code,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_atom")
    sudo rabbitmqctl status | awk '/{atom,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "memory_other_system")
    sudo rabbitmqctl status | awk '/{other_system,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "file_total_limit")
    sudo rabbitmqctl status | awk '/{total_limit,[0-9]+/' | awk -F "[{,}]" '{print $3}'
    ;;
    "file_total_used")
    sudo rabbitmqctl status | awk '/{total_used,[0-9]+/' | awk -F "[{,}]" '{print $7}'
    ;;
    "sockets_limit")
    sudo rabbitmqctl status | awk '/{sockets_limit,[0-9]+/' | awk -F "[{,}]" '{print $11}'
    ;;
    "sockets_used")
    sudo rabbitmqctl status | awk '/{sockets_used,[0-9]+/' | awk -F "[{,}]" '{print $15}'
    ;;
    "proc_limit")
    sudo rabbitmqctl status | awk '/{limit,[0-9]+/' | awk -F "[{,}]" '{print $5}'
    ;;
    "proc_used")
    sudo rabbitmqctl status | awk '/{used,[0-9]+/' | awk -F "[{,}]" '{print $9}'
    ;;
    esac
fi

