#!/usr/bin/bash

if [[ -e ~/upk.d/env.sh ]]; then
   source ~/upk.d/env.sh
fi

proc_name="caddy"
runtime_dir=${CADDY_runtime_dir:-~/upk.d/runs/${proc_name}}
conf_file=${runtime_dir}/caddyfile

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
installed_dir=$self_dir
exec_path=${installed_dir}/${proc_name}

if [[ ! -d $runtime_dir ]]; then
   mkdir -p $runtime_dir
fi

start_service() {
   if ! pidof $proc_name &>/dev/null; then
      nohup $exec_path run --environ --config $conf_file &>/dev/null &
   fi
}

reload_service() {
   if pidof $proc_name &>/dev/null; then
      $exec_path reload --config $conf_file --force
   fi
}

stop_service() { pidof $proc_name | xargs kill &>/dev/null; }

trust_certs() { $exec_path trust; }

case $1 in
   start)
      start_service
      ;;
   stop)
      stop_service
      ;;
   reload)
      reload_service
      ;;
   restart)
      stop_service
      start_service
      ;;
   trust)
      trust_certs
      ;;
   *)
      echo "usage: $(basename $0) <start|stop|reload|restart|trust>"
      echo "permission: setcap 'cap_net_admin,cap_net_bind_service=+ep' caddy"
esac
