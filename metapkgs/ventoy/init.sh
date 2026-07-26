#!/bin/bash

exec_path=${installed_dir}/ventoy-gui.sh
cli_name=ventoy-cli.sh

install_pkg() {
   local repo="ventoy/Ventoy"
   local filename_tpl="ventoy-${ver_holder}-linux.tar.gz"

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

   unpack_dir=${cache_dir}/${pkg_id}-${remote_ver}
   tar xf $save_path -C $cache_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"

   cp -f ${metapkg_dir}/launch.sh ${installed_dir}/
   echo "==> installed '$(tilde_path ${installed_dir}/launch.sh)'"
   cp -f ${metapkg_dir}/${cli_name} ${bins_dir}/
   echo "==> installed '$(tilde_path ${bins_dir}/${cli_name})'"
}
