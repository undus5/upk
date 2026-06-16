#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/Browser/start-tor-browser

fetch_html_ver() {
   local url=""https://dist.torproject.org/torbrowser/""
   local pattern_v="[0-9]+\.[0-9]+\.[0-9]+"
   local pattern_h="href=\"${pattern_v}"
   curl -sL $url | grep -Eo "$pattern_h" | grep -Eo "$pattern_v"
}

install_pkg() {
   test_var installed_dir $installed_dir
   local local_ver=$(get_local_ver)
   [[ "$local_ver" == "locked" ]] && exit 0
   local remote_ver=$(fetch_html_ver)
   [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]] && exit 0
   local filename="tor-browser-linux-x86_64-${remote_ver}.tar.xz"
   local dl_url="https://www.torproject.org/dist/torbrowser"
   dl_url+="/${remote_ver}/${filename}"
   save_path=${cache_dir}/${filename}
   echo "==> downloading '${filename}' ..."
   if [[ -f "${save_path}" ]]; then
      echo "==> found in cache"
   else
      curl --create-dirs -o ${save_path} -#L ${dl_url}
   fi
   # backup old installed
   [[ -d $cache_old ]] && rm -rf $cache_old
   [[ -d $installed_dir ]] && mv $installed_dir $cache_old
   # backup end
   unpack_dir=${cache_dir}/${pkg_id}
   tar xf ${save_path} -C ${cache_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   lock_ver
}

source ${upk_src}/includes/metapkg-post.in

