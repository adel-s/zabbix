#!/bin/bash
#
# Important! Don't forget to set in /etc/zabbix/zabbix_agentd.conf:
# #Option: Timeout
# Timeout=30

if [[ -z "$1" || -z "$2" ]]
then
  echo "Missing incoming values. Use: extping.sh host metric"
  exit 1
fi

host=$1
metric=$2
ping_counts='10'

CACHE_TTL="55"
CACHE_FILE="/tmp/zabbix.extping.$host.cache"
EXEC_TIMEOUT="1"
NOW_TIME=`date '+%s'`

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
 DATACACHE=`ping $host -c $ping_counts 2>&1`
 echo "${DATACACHE}" > "${CACHE_FILE}"
 chmod 640 "${CACHE_FILE}"
fi

case $metric in
 "avg_time")
  fping -e $host | awk '{print $4}' | tr -d '('
 ;;
 "packet_loss")
  cat $CACHE_FILE | sed -n 's/^.* \([0-9]*\)% packet loss.*$/\1/p'
 ;;
 "errors")
  errors_count=$(cat $CACHE_FILE | sed -n 's/^.* +\([0-9]*\) errors.*$/\1/p')
  if [[ -z "$errors_count" ]]; then
   errors_count='0'
  fi
  echo $errors_count
 ;;
 *)
 echo "unknown metric"
 ;;
esac