#!/bin/bash

exec_path=${installed_dir}/${pkg_id}

install_pkg() {
   local repo="peazip/PeaZip"
   local filename_tpl="peazip_portable-${ver_holder}.LINUX.Qt6.x86_64.tar.gz"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${save_path%.tar.*}
   tar xf $save_path -C $cache_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}
