#!/usr/bin/bash

proc_name="filebrowser"
default_port=8586
port=${FILEBROWSER_port:-$default_port}
public_dir=${FILEBROWSER_public_dir:-~/Public}
runtime_dir=${FILEBROWSER_runtime_dir:-~/upk.d/runs/${proc_name}}
db_file=${runtime_dir}/${proc_name}.db

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
installed_dir=$self_dir
exec_path=${installed_dir}/${proc_name}

if [[ ! -d $runtime_dir ]]; then
   mkdir -p $runtime_dir
fi

if (( port < 1024 || port > 65535 )); then
   port=$default_port
fi

start_service() {
   if ! pidof $proc_name &>/dev/null; then
      nohup $exec_path -d $db_file -p $port -r $public_dir &>/dev/null &
   fi
}

stop_service() { pidof $proc_name | xargs kill &>/dev/null; }

case $1 in
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
      printf "usage: $(basename $0) <start|stop|reload|restart>\n"
esac
