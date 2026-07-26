#!/bin/bash

cli_name="$pkg_id"

install_pkg() {
   local repo="jesseduffield/lazygit"
   local filename_tpl="lazygit_${ver_holder}_linux_x86_64.tar.gz"

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

   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p $unpack_dir
   tar xf $save_path -C $unpack_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}
