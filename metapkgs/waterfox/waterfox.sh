#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/waterfox

install_pkg() {
   test_var installed_dir $installed_dir
   local repo="BrowserWorks/waterfox"
   local filename_tpl="waterfox-${ver_placeholder}.tar.bz2"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"

   dl_url="https://cdn.waterfox.com/waterfox/releases/${remote_ver}"
   dl_url+="/Linux_x86_64/${filename}"
   save_path=${cache_dir}/${filename}

   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}
   tar xf ${save_path} -C ${cache_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   lock_ver
}

source ${upk_src}/includes/metapkg-post.in

