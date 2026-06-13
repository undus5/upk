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
   dl_file=${cache_dir}/${filename}
   echo "==> downloading ${filename} ..."
   if [[ -f "${dl_file}" ]]; then
      echo "==> found in cache"
   else
      curl --create-dirs -o ${dl_file} -#L ${dl_url}
   fi
   # backup old installed
   [[ -d $cache_old ]] && rm -rf $cache_old
   [[ -d $installed_dir ]] && mv $installed_dir $cache_old
   # backup end
   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p $unpack_dir
   chmod u+x $dl_file
   cp $dl_file ${unpack_dir}/
   ${metapkg_dir}/bubblewrap.sh $unpack_dir ~/${filename}
   rm ${unpack_dir}/${filename}
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

