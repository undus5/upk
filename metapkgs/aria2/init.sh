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
   local f=${bins_dir}/${exec_name}
   if [[ -f $f ]]; then
      rm -f $f
      echo "==> removed '$(tilde_path $f)'"
   fi
}
