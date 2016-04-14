#!/bin/bash
##### OPTIONS VERIFICATION #####
if [[ -z "$1" ]]; then
 echo 'Usage: telegram-status.sh port'
 exit 1
fi

port=$1
exit_code=$(nc -z -w5 localhost $port; echo $?)

if [ "$exit_code" = "0" ]; then echo 1; else echo 0; fi
