#!/bin/bash

exec_name="aria2.sh"

install_pkg() {
   echo "==> 1. install aria2 from distro package manager"
   echo "==> 2. run 'upk.sh enable aria2'"
   exit 0   # prevent post_enable()
}

post_enable() {
   cp -f ${metapkg_dir}/${exec_name} ${bins_dir}/
   echo "==> installed '$(tilde_path ${bins_dir}/${exec_name})'"
}

post_disable() {
   post_disable_cli
}

is_installed() {
   if command -v aria2c &>/dev/null; then
      echo "[installed]"
   fi
}

is_enabled() {
   is_enabled_cli
}
