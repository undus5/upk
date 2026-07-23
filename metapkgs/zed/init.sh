#!/bin/bash

exec_path=${installed_dir}/bin/zed

install_pkg() {
   local repo="zed-industries/zed"
   local filename_tpl="zed-linux-x86_64.tar.gz"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   if [[ -n "$path_url" ]]; then
      printf "\n"
   else
      rtnf "up to date"
   fi
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"

   save_path="${save_path%.tar.gz}-${remote_ver}.tar.gz"

   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/zed.app
   tar xf $save_path -C $cache_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}
