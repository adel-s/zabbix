#!/bin/bash
CACHE_TTL="55"
CACHE_FILE="/tmp/zabbix.meminfo.cache"
EXEC_TIMEOUT="1"
NOW_TIME=`date '+%s'`

if [[ -z "$1"  ]]
then
  echo "Missing metric"
  exit 1
fi

METRIC=$1

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
  DATACACHE=`sudo /bin/cat /proc/meminfo | sed 's/kB$//' |  sed 's/  *//' 2>&1 | sed 's/[()]/_/g'`
  echo "${DATACACHE}" > "${CACHE_FILE}"
  chmod 640 "${CACHE_FILE}"
fi

case $METRIC in
 "Apps")
        MemTotal=$(cat "${CACHE_FILE}" | grep -P "^MemTotal:" | awk -F ":" '{print $2'})
        MemFree=$(cat "${CACHE_FILE}" | grep -P "^MemFree:" | awk -F ":" '{print $2'})
        Buffers=$(cat "${CACHE_FILE}" | grep -P "^Buffers:" | awk -F ":" '{print $2'})
        Cached=$(cat "${CACHE_FILE}" | grep -P "^Cached:" | awk -F ":" '{print $2'})
        Slab=$(cat "${CACHE_FILE}" | grep -P "^Slab:" | awk -F ":" '{print $2'})
        PageTables=$(cat "${CACHE_FILE}" | grep -P "^PageTables:" | awk -F ":" '{print $2'})
        SwapCached=$(cat "${CACHE_FILE}" | grep -P "^SwapCached:" | awk -F ":" '{print $2'})
        result=$(($MemTotal - $MemFree - $Buffers - $Cached - $Slab - $PageTables - $SwapCached))
        ;;
 "SwapUsed")
        SwapTotal=$(cat "${CACHE_FILE}" | grep -P "^SwapTotal:" | awk -F ":" '{print $2'})
        SwapFree=$(cat "${CACHE_FILE}" | grep -P "^SwapFree:" | awk -F ":" '{print $2'})
        result=$(($SwapTotal - $SwapFree))
        ;;
 "Used")
        MemTotal=$(cat "${CACHE_FILE}" | grep -P "^MemTotal:" | awk -F ":" '{print $2'})
        MemFree=$(cat "${CACHE_FILE}" | grep -P "^MemFree:" | awk -F ":" '{print $2'})
        Buffers=$(cat "${CACHE_FILE}" | grep -P "^Buffers:" | awk -F ":" '{print $2'})
        Cached=$(cat "${CACHE_FILE}" | grep -P "^Cached:" | awk -F ":" '{print $2'})
        result=$(($MemTotal - $MemFree - $Buffers - $Cached))
        ;;
 *)
        result=$(cat "${CACHE_FILE}" | grep -P "^${METRIC}:" | awk -F ":" '{print $2'})
        ;;
esac

output=$(($result * 1024))
echo $output
