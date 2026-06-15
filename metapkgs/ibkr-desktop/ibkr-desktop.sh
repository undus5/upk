#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}

install_pkg() {
   test_var cache_old $cache_old
   test_var installed_dir $installed_dir
   local local_ver=$(get_local_ver)
   [[ "$local_ver" == "locked" ]] && exit 0

   local filename="ntws-latest-standalone-linux-x64.sh"
   local dl_url="https://download2.interactivebrokers.com/installers/ntws"
   dl_url+="/latest-standalone/${filename}"
   save_path=${cache_dir}/${filename}

   download_file "$dl_url" "$save_path"
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p $unpack_dir
   chmod u+x $save_path
   cp $save_path ${unpack_dir}/
   ${metapkg_dir}/bubblewrap.sh $unpack_dir ~/${filename}
   rm -f ${unpack_dir}/${filename}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   lock_ver
}

launch_pkg() {
   test_var metapkg_dir $metapkg_dir
   test_var installed_dir $installed_dir
   ${metapkg_dir}/bubblewrap.sh $installed_dir ~/ntws/ntws
}

source ${upk_src}/includes/metapkg-post.in

