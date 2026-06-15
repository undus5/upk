#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/${pkg_id}.AppImage

# https://github.com/NeverDecaf/chromium-web-store

fetch_release_ver() {
   test_cmd curl; test_cmd jq
   local release_api="https://api.github.com/repos"
   local release_api+="/ungoogled-software/ungoogled-chromium/releases"
   local binary_api="https://api.github.com/repos"
   local binary_api+="/ungoogled-software/ungoogled-chromium-binaries"
   local binary_api+="/contents/config/platforms/appimage/64bit"

   local jq_filters="[limit(3;.[])]|map(.tag_name)|join(\" \")"
   local rvers=()
   read -r -a rvers <<< "$(curl -sL ${release_api} | jq -r "${jq_filters}")"

   jq_filters="map(select(.name|test(\"^[0-9]{3}.\")).name)|reverse"
   jq_filters+="|[limit(5;.[])]|[.[]|rtrimstr(\".ini\")]|join(\" \")"
   local bvers=()
   read -r -a bvers <<< "$(curl -sL ${binary_api} | jq -r "${jq_filters}")"

   local remote_ver=
   for rver in "${rvers[@]}"; do
      for bver in "${bvers[@]}"; do
         if [[ "$rver" == "$bver" ]]; then
            remote_ver=$rver; break
         fi
      done
      [[ -n "$remote_ver" ]] && break
   done
   echo $remote_ver
}

compare_vers() {
   local remote_ver="$1"
   local ver_pattern="^[0-9]+(.[0-9]+){3}-[0-9]+(.[0-9]+)*$"
   [[ "$remote_ver" =~ $ver_pattern ]] || errf "==> invalid remote_ver"
   local local_ver="$2"
   local result=""
   local rver1=
   local rver2=
   local rvers=
   local lver1=
   local lver2=
   local lvers=
   local rver=
   local lver=
   if [[ -z "$local_ver" ]]; then
      result=$remote_ver
   else
      [[ "$local_ver" =~ $ver_pattern ]] || errf "==> invalid local_ver"
      # version example: 148.0.7778.215-1
      IFS="-" read -r rver1 rver2 <<< "$remote_ver"
      IFS="." read -r -a rvers <<< "$rver1"
      rvers+=("$rver2")
      IFS="-" read -r lver1 lver2 <<< "$local_ver"
      IFS="." read -r -a lvers <<< "$lver1"
      lvers+=("$lver2")
      for i in "${!rvers[@]}"; do
         rver=${rvers[i]}
         lver=${lvers[i]}
         if (( rver > lver )); then
            result=$remote_ver
            break
         fi
      done
   fi
   echo $result
}

install_pkg() {
   test_var cache_old $cache_old
   test_var installed_dir $installed_dir
   test_var exec_path $exec_path
   local local_ver=$(get_local_ver)
   [[ "$local_ver" == "locked" ]] && exit 0

   printf "==> checking update for $pkg_id ... "
   local remote_ver=$(fetch_release_ver)
   remote_ver=$(compare_vers $remote_ver $local_ver)
   [[ -n "$remote_ver" ]] && printf "\n" || rtnf "up to date"

   local filename="ungoogled-chromium-${remote_ver}-x86_64.AppImage"
   local dl_url="https://github.com"
   dl_url+="/ungoogled-software/ungoogled-chromium-portablelinux"
   dl_url+="/releases/download/${remote_ver}/${filename}"
   save_path=${cache_dir}/${filename}

   download_file "$dl_url" "$save_path"
   backup_old_installed

   mkdir -p $installed_dir
   chmod u+x $save_path
   cp $save_path $exec_path
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

source ${upk_src}/includes/metapkg-post.in

