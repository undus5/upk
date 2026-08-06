#!/bin/bash

proc_name="aria2c"

start_service() {
   if pidof $proc_name &>/dev/null; then
      exit 0
   fi
   local ddir=$(realpath ~/Downloads)
   # best_aria2, all_aria2, http_aria2, nohttp_aria2
   local trackers=$(curl -sL "https://cf.trackerslist.com/best_aria2.txt")
   local exec="${proc_name} --enable-rpc=true --rpc-secret=${proc_name}"
   exec+=" --rpc-listen-port=6800 --bt-stop-timeout=3600"
   exec+=" --dir=${ddir} --bt-tracker=${trackers}"
   nohup $exec &>/dev/null &
}

stop_service() {
   local pid=$(pidof $proc_name)
   if [[ -n "$pid" ]]; then
      echo "$pid" | xargs kill -9 &>/dev/null
   fi
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
      echo "usage: $(basename ${0}) <start|stop|reload|restart>"
      ;;
esac
