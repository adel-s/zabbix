#!/bin/bash
##### OPTIONS VERIFICATION #####
if [[ -z "$1" ]]; then
    echo "Please set metric"
    exit 1
fi
##### PARAMETERS #####
METRIC="$1"

CACHE_TTL="55"
CACHE_FILE="/tmp/zabbix.sockets-stats.cache"
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
  sudo /bin/ss -m -a -n -A 'unix,tcp' >${CACHE_FILE} 2>/dev/null
  chmod 640 "${CACHE_FILE}"
fi

case $METRIC in
    'tcp_total')
        cat ${CACHE_FILE} | grep -E '^tcp' |wc -l
        ;;
    'tcp_wait')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*TIME-WAIT' | wc -l
        ;;
    'tcp_estab')
	cat ${CACHE_FILE} | grep -E '^tcp[ ]*ESTAB' | wc -l
        ;;
    'tcp_syn-sent')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*SYN-SENT' | wc -l
        ;;
    'tcp_syn-recv')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*SYN-RECV' | wc -l
        ;;
    'tcp_fin-wait-1')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*FIN-WAIT-1' | wc -l
        ;;
    'tcp_fin-wait-2')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*FIN-WAIT-2' | wc -l
        ;;
    'tcp_close')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*CLOSE' | wc -l
        ;;
    'tcp_close-wait')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*CLOSE-WAIT' | wc -l
        ;;
    'tcp_last-ack')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*LAST-ACK' | wc -l
        ;;
    'tcp_listen')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*LISTEN' | wc -l
        ;;
    'tcp_closing')
        cat ${CACHE_FILE} | grep -E '^tcp[ ]*CLOSING' | wc -l
        ;;
    'unix_total')
        cat ${CACHE_FILE} | grep -E '^u_str' |wc -l
        ;;
    'unix_listen')
        cat ${CACHE_FILE} | grep -E '^u_str[ ]*LISTEN' |wc -l
        ;;
    'unix_estab')
        cat ${CACHE_FILE} | grep -E '^u_str[ ]*ESTAB' |wc -l
        ;;
    'mem_r')
     cat ${CACHE_FILE} | grep 'mem' | sed 's/^[ \t]*mem:(//' | sed 's/)$//' | sed 's/[a-z]*//g' | awk -F ',' '{print $1}' | awk 'BEGIN{sum=0}{sum+=$1}END{printf("%.0f\n", sum)}'
	;;
    'mem_w')
     cat ${CACHE_FILE} | grep 'mem' | sed 's/^[ \t]*mem:(//' | sed 's/)$//' | sed 's/[a-z]*//g' | awk -F ',' '{print $2}' | awk 'BEGIN{sum=0}{sum+=$1}END{printf("%.0f\n", sum)}'
        ;;
    'mem_f')
     cat ${CACHE_FILE} | grep 'mem' | sed 's/^[ \t]*mem:(//' | sed 's/)$//' | sed 's/[a-z]*//g' | awk -F ',' '{print $3}' | awk 'BEGIN{sum=0}{sum+=$1}END{printf("%.0f\n", sum)}'
        ;;
    'mem_t')
     cat ${CACHE_FILE} | grep 'mem' | sed 's/^[ \t]*mem:(//' | sed 's/)$//' | sed 's/[a-z]*//g' | awk -F ',' '{print $4}' | awk 'BEGIN{sum=0}{sum+=$1}END{printf("%.0f\n", sum)}'
        ;;
     *)
        echo "Not selected metric"
        exit 0
        ;;
esac

