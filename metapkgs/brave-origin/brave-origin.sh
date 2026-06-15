#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
metapkg_dir=${metapkg_dir:-$self_dir}
pkg_id=brave-origin
channel=${channel:-release}
[[ "$channel" != "release" ]] && pkg_id+="-${channel}"
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/${pkg_id}

fetch_latest_ver() {
   test_cmd curl
   local api_url="https://versions.brave.com/latest"
   api_url+="/origin-${channel}-linux-x64.version"
   curl -sL ${api_url}
}

install_pkg() {
   test_var cache_old $cache_old
   test_var installed_dir $installed_dir
   local local_ver=$(get_local_ver)
   [[ "$local_ver" == "locked" ]] && exit 0
   local remote_ver=$(fetch_latest_ver)
   [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]] && exit 0
   local api_url="https://api.github.com/repos/brave/brave-browser"
   api_url+="/releases/tags/v${remote_ver}"
   local filename="${pkg_id}-${remote_ver}-linux-amd64.zip"
   test_cmd curl; test_cmd jq
   local dl_url=$(curl -sL $api_url | jq -r "$(jq_dl_url_filter $filename)")
   local save_path=${cache_dir}/${filename}
   echo "==> downloading ${filename} ..."
   if [[ -f "${save_path}" ]]; then
      echo "==> found in cache"
   else
      curl --create-dirs -o ${save_path} -#L ${dl_url}
   fi
   # backup old installed
   [[ -d $cache_old ]] && rm -rf $cache_old
   [[ -d $installed_dir ]] && mv $installed_dir $cache_old
   # backup end
   unpack_dir=${save_path%.*}
   mkdir ${unpack_dir}
   echo "==> unpacking ${filename} ..."
   unzip -q ${save_path} -d ${unpack_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

source ${upk_src}/includes/metapkg-post.in

