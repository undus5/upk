#!/bin/bash

PROC_NAME="aria2c"

start_service() {
   if pidof $PROC_NAME &>/dev/null; then
      exit 0
   fi
   local DDIR=$(realpath ~/Downloads)
   # best_aria2, all_aria2, http_aria2, nohttp_aria2
   local TRACKERS=$(curl -sL "https://cf.trackerslist.com/best_aria2.txt")
   local EXEC="${PROC_NAME} --enable-rpc=true --rpc-secret=${PROC_NAME}"
   EXEC+=" --rpc-listen-port=6800 --bt-stop-timeout=3600"
   EXEC+=" --dir=${DDIR} --bt-tracker=${TRACKERS}"
   nohup $EXEC &>/dev/null &
}

stop_service() {
   local PID=$(pidof $PROC_NAME)
   [[ -z "$PID" ]] || echo "$PID" | xargs kill -9 &>/dev/null
}

case ${1} in
   start)
      start_service
      ;;
   stop)
      stop_service
      ;;
   reload|restart)
      stop_service
      start_service
      ;;
   *)
      echo "Usage: $(basename ${0}) <start|stop|reload|restart>"
      ;;
esac
