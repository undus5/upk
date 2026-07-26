#!/bin/bash

cli_name=open-terminal-here.sh
xdg_cli=${bins_dir}/xdg-terminal-exec

install_pkg() {
   test_var installed_dir $installed_dir
   test_var cli_name $cli_name

   local local_ver=$(get_local_ver)
   if [[ "$local_ver" == "locked" ]]; then
      exit 0
   fi

   mkdir -p $installed_dir
   self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
   cp -f ${metapkg_dir}/${cli_name} ${installed_dir}/
   echo "==> installed '$(tilde_path ${installed_dir})/${cli_name}'"
   lock_ver
}

post_disable() {
   if [[ -e $cli_name ]]; then
      rm -f $cli_name
      echo "==> removed '$(tilde_path ${bins_dir}/${cli_name})'"
   fi
   if [[ -e $xdg_cli ]]; then
      rm -f $xdg_cli
      echo "==> removed '$(tilde_path $xdg_cli)'"
   fi
}
