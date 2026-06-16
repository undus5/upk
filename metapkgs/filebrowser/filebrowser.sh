#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}

install_pkg() {
   local repo="filebrowser/filebrowser"
   local filename_tpl="linux-amd64-filebrowser.tar.gz"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p $unpack_dir
   tar xf ${save_path} -C ${unpack_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

post_enable() {
   cp -f ${metapkg_dir}/fbrowser.sh ${bins_dir}/
   echo "==> installed '$(tilde_path ${bins_dir}/fbrowser.sh)'"
}

post_disable() {
   local f=${bins_dir}/fbrowser.sh
   if [[ -f $f ]]; then
      rm -f $f
      echo "==> removed '$(tilde_path $f)'"
   fi
}

source ${upk_src}/includes/metapkg-post.in

