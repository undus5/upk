#!/usr/bin/bash

if [[ -e ~/upk.d/env.sh ]]; then
   source ~/upk.d/env.sh
fi

PROC_NAME="caddy"
RUNTIME_DIR=${CADDY_RUNTIME_DIR:-~/upk.d/runs/${PROC_NAME}}
CONF_FILE=${RUNTIME_DIR}/caddyfile

SELF_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
INSTALLED_DIR=$SELF_DIR
EXEC_PATH=${INSTALLED_DIR}/${PROC_NAME}

if [[ ! -d $RUNTIME_DIR ]]; then
   mkdir -p $RUNTIME_DIR
fi

start_service() {
   if ! pidof $PROC_NAME &>/dev/null; then
      nohup $EXEC_PATH run --environ --config $CONF_FILE &>/dev/null &
   fi
}

reload_service() {
   if pidof $PROC_NAME &>/dev/null; then
      $EXEC_PATH reload --config $CONF_FILE --force
   fi
}

stop_service() { pidof $PROC_NAME | xargs kill &>/dev/null; }

trust_certs() { $EXEC_PATH trust; }

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
      echo "Usage: $(basename $0) <start|stop|reload|restart|trust>"
      echo "Permission: setcap 'cap_net_admin,cap_net_bind_service=+ep' caddy"
esac
