#!/bin/bash
if [[ -z "$1" ]]
then
  echo "Missing metric"
  exit 1
fi

metric=$1


##### RUN #####
    case $metric in
    "State")
     sudo /opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -LAll -aAll -nolog | grep -E '^'$metric'' | awk -F ' : ' '{print $2}'
    ;;
    esac
