#!/usr/bin/bash

# ~/.local/share/filebrowser/config.in
# PORT=8586
# PUBLIC_DIR=~/Public

db_dir=~/.local/share/filebrowser
[[ -d $db_dir ]] || mkdir -p $db_dir

db_file=${db_dir}/filebrowser.db

conf_in=${db_dir}/config.in
[[ -f $conf_in ]] && source $conf_in

port=
[[ -n "$PORT" ]] && port=$PORT
(( port > 1024 && port < 65536 )) || port=
port=${port:-8586}

pub_dir=
[[ -n "$PUBLIC_DIR" ]] && pub_dir=$(realpath $PUBLIC_DIR)
pub_dir=${pub_dir:-$(realpath ~/Public)}

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
upk_data=$(dirname $self_dir)
exec_path=${upk_data}/apps/filebrowser/filebrowser

test_proc() { pidof "$@" &>/dev/null; }
bgr() { nohup "$@" &>/dev/null & }

start_serv() {
   test_proc filebrowser || bgr $exec_path -d $db_file -p $port -r $pub_dir
}

stop_serv() { pidof filebrowser | xargs kill &>/dev/null; }

case $1 in
   ""|start)
      start_serv
      ;;
   stop)
      stop_serv
      ;;
   restart)
      stop; start
      ;;
   *)
      printf "Usage: $(basename $0) <start|stop|restart>\n"
esac

