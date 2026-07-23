#!/bin/bash

exec_path=${installed_dir}/${pkg_id}

channel=${pkg_id#brave-origin}
channel=${channel#-}
channel=${channel:-release}

fetch_latest_ver() {
   test_cmd curl
   local api_url="https://versions.brave.com/latest"
   api_url+="/origin-${channel}-linux-x64.version"
   curl -sL ${api_url}
}

install_pkg() {
   local local_ver=$(get_local_ver)
   if [[ "$local_ver" == "locked" ]]; then
      exit 0
   fi
   local remote_ver=$(fetch_latest_ver)
   if [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]]; then
      exit 0
   fi
   local api_url="https://api.github.com/repos/brave/brave-browser"
   api_url+="/releases/tags/v${remote_ver}"
   local filename="${pkg_id}-${remote_ver}-linux-amd64.zip"
   local dl_url=$(curl -sL $api_url | jq -r "$(jq_dl_url_filter $filename)")
   local save_path=${cache_dir}/${filename}

   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${save_path%.*}
   mkdir ${unpack_dir}
   echo "==> unpacking ${filename} ..."
   unzip -q ${save_path} -d ${unpack_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}
