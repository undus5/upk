#!/usr/bin/bash

db_file=
port=${FILE_BROWSER_PORT:-8182}
share_dir=${FILE_BROWSER_DIR:-$(realpath ~/Public)}

if [[ -n $FILE_BROWSER_DB && -d $FILE_BROWSER_DB ]]; then
   db_file=$FILE_BROWSER_DB
else
   db_dir=~/.local/share/filebrowser
   [[ -d $db_dir ]] || mkdb_dir -p $db_dir
   db_file=${db_dir}/filebrowser.db
fi

test_proc() { pidof "$@" &>/dev/null; }
bgr() { nohup "$@" &>/dev/null & }

start_serv() {
   local exec="filebrowser -d $db_file -p $port -r $share_dir"
   test_proc filebrowser || bgr ${exec}
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
   --)
      shift; filebrowser $@
      ;;
   *)
      printf "Usage: $(basename $0) <start|stop|restart|-- <fb_opts>>\n"
esac

