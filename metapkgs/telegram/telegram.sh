#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/Telegram

install_pkg() {
   local repo="telegramdesktop/tdesktop"
   local filename_tpl="tsetup.${ver_placeholder}.tar.xz"

   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] || exit 1
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/Telegram
   tar xf ${dl_file} -C ${cache_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   lock_ver
}

source ${upk_src}/includes/metapkg-post.in

