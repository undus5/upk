#!/bin/bash

exec_name="$pkg_id"

install_pkg() {
   local repo="pythops/impala"
   local filename_tpl="impala-x86_64-unknown-linux-musl"

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

   mkdir -p $installed_dir
   chmod u+x $save_path
   cp -f $save_path ${installed_dir}/${pkg_id}
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

post_enable() {
   ln -sf ${installed_dir}/${pkg_id} ${bins_dir}/
   echo "==> linked '$(tilde_path ${bins_dir}/${pkg_id})'"
}
