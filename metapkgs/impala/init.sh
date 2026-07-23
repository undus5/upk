#!/bin/bash

install_pkg() {
   local repo="pythops/impala"
   local filename_tpl="impala-x86_64-unknown-linux-musl"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
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

post_disable() {
   local l=${bins_dir}/${pkg_id}
   if [[ -L $l ]]; then
      rm -f $l
      echo "==> removed '$(tilde_path $l)'"
   fi
}
