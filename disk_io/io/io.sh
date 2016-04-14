#!/bin/bash
export LC_ALL=""
export LANG="en_US.UTF-8"
#
if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
 ##### DISCOVERY #####
 DEVICES=`iostat -d | awk '{print $1}' | sed -e '/^\([hsv]d[a-z]\)$/!d'`

 if [[ -n ${DEVICES} ]]; then
    JSON="{ \"data\":["
    SEP=""
    for DEV in ${DEVICES}; do
      JSON=${JSON}"$SEP{\"{#HDNAME}\":\"${DEV}\"}"
      SEP=", "
    done
    JSON=${JSON}"]}"
    echo ${JSON}
  fi
  exit 0
fi
##### PARAMETERS #####
RESERVED="$1"
METRIC="$2"
DISK="$3"
CACHE_TTL="25"
CACHE_FILE="/tmp/zabbix.iostat.cache"
EXEC_TIMEOUT="2"
NOW_TIME=`date '+%s'`
##### RUN #####
if [ ${METRIC} = "read" ]; then
  iostat -k | grep ${DISK} | head -n 1 | awk '{print $5}'
  exit 0
fi
if [ ${METRIC} = "write" ]; then
  iostat -k | grep ${DISK} | head -n 1 | awk '{print $6}'
  exit 0
fi
##### CACHE #####
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
  DATACACHE=`iostat -x 1 2 2>&1`
  echo "${DATACACHE}" > "${CACHE_FILE}"
  chmod 640 "${CACHE_FILE}"
fi
#
if [ ${METRIC} = "util" ]; then
  cat ${CACHE_FILE} | grep ${DISK} | tail -n 1 | awk '{print $14}'
  exit 0
fi
if [ ${METRIC} = "svctm" ]; then
  cat ${CACHE_FILE} | grep ${DISK} | tail -n 1 | awk '{print $13}'
  exit 0
fi
if [ ${METRIC} = "await" ]; then
  cat ${CACHE_FILE} | grep ${DISK} | tail -n 1 | awk '{print $10}'
  exit 0
fi
if [ ${METRIC} = "avgqu" ]; then
  cat ${CACHE_FILE} | grep ${DISK} | tail -n 1 | awk '{print $9}'
  exit 0
fi
if [ ${METRIC} = "rs" ]; then
  cat ${CACHE_FILE} | grep ${DISK} | tail -n 1 | awk '{print $4}'
  exit 0
fi
if [ ${METRIC} = "ws" ]; then
  cat ${CACHE_FILE} | grep ${DISK} | tail -n 1 | awk '{print $5}'
  exit 0
fi
