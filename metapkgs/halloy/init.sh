#!/bin/bash

exec_path=${installed_dir}/bin/halloy

install_pkg() {
   local repo="squidowl/halloy"
   local filename_tpl="halloy-${ver_holder}-x86_64-linux.tar.gz"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   if [[ -n "$path_url" ]]; then
      printf "\n"
   else
      rtnf "up to date"
   fi
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${save_path%.tar.*}
   mkdir -p ${unpack_dir}
   tar xf $save_path -C $unpack_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}
