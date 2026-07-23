#!/usr/bin/bash

if [[ -e ~/upk.d/env.sh ]]; then
   source ~/upk.d/env.sh
fi

PROC_NAME="filebrowser"
DEFAULT_PORT=8586
PORT=${FILEBROWSER_PORT:-$DEFAULT_PORT}
PUBLIC_DIR=${FILEBROWSER_PUBLIC_DIR:-~/Public}
RUNTIME_DIR=${FILEBROWSER_RUNTIME_DIR:-~/upk.d/runs/${PROC_NAME}}
DB_FILE=${RUNTIME_DIR}/${PROC_NAME}.db

SELF_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
INSTALLED_DIR=$SELF_DIR
EXEC_PATH=${INSTALLED_DIR}/${PROC_NAME}

if [[ ! -d $RUNTIME_DIR ]]; then
   mkdir -p $RUNTIME_DIR
fi

if (( PORT < 1024 || PORT > 65535 )); then
   PORT=$DEFAULT_PORT
fi

start_service() {
   if ! pidof $PROC_NAME &>/dev/null; then
      nohup $EXEC_PATH -d $DB_FILE -p $PORT -r $PUBLIC_DIR &>/dev/null &
   fi
}

stop_service() { pidof $PROC_NAME | xargs kill &>/dev/null; }

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
      printf "Usage: $(basename $0) <start|stop|reload|restart>\n"
esac
