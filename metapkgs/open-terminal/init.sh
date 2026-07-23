#!/bin/bash

exec_name=open-terminal-here.sh
exec_path=${installed_dir}/${exec_name}
xdg_exec=${bins_dir}/xdg-terminal-exec

install_pkg() {
   test_var installed_dir $installed_dir
   test_var exec_name $exec_name

   local local_ver=$(get_local_ver)
   [[ "$local_ver" == "locked" ]] && exit 0

   mkdir -p $installed_dir
   self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
   cp -f ${self_dir}/${exec_name} ${installed_dir}/
   echo "==> installed '$(tilde_path ${installed_dir})/${exec_name}'"
   lock_ver
}

post_enable() {
   ln -sf ../apps/${pkg_id}/${exec_name} $xdg_exec
   echo "==> installed '$(tilde_path $xdg_exec)'"
}

post_disable() {
   if [[ -L $xdg_exec ]]; then
      rm -f $xdg_exec
      echo "==> removed '$(tilde_path $xdg_exec)'"
   fi
}
