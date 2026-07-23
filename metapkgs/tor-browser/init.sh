#!/bin/bash

exec_path=${installed_dir}/Browser/start-tor-browser

fetch_html_ver() {
   local url=""https://dist.torproject.org/torbrowser/""
   local pattern_v="[0-9]+\.[0-9]+\.[0-9]+"
   local pattern_h="href=\"${pattern_v}"
   curl -sL $url | grep -Eo "$pattern_h" | grep -Eo "$pattern_v"
}

install_pkg() {
   local local_ver=$(get_local_ver)
   if [[ "$local_ver" == "locked" ]]; then
      exit 0
   fi
   local remote_ver=$(fetch_html_ver)
   if [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]]; then
      exit 0
   fi
   local filename="tor-browser-linux-x86_64-${remote_ver}.tar.xz"
   local dl_url="https://www.torproject.org/dist/torbrowser"
   dl_url+="/${remote_ver}/${filename}"
   save_path=${cache_dir}/${filename}

   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}
   tar xf $save_path -C $cache_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   lock_ver
}
