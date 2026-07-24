#!/bin/bash

exec_name="filebrowser.sh"

install_pkg() {
   local repo="filebrowser/filebrowser"
   local filename_tpl="linux-amd64-filebrowser.tar.gz"

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

   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p $unpack_dir
   tar xf $save_path -C $unpack_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

post_enable() {
   cp -f ${metapkg_dir}/${exec_name} ${installed_dir}/
   echo "==> installed '$(tilde_path ${installed_dir}/${exec_name})'"
   ln -sf ../apps/${pkg_id}/${exec_name} ${bins_dir}/
   echo "==> installed '$(tilde_path ${bins_dir}/${exec_name})'"
}

post_disable() {
   post_disable_cli
}

is_enabled() {
   is_enabled_cli
}
