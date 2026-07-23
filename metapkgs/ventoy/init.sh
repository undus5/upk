#!/bin/bash

exec_path=${installed_dir}/launch.sh
exec_cli=ventoy-cli.sh

install_pkg() {
   local repo="ventoy/Ventoy"
   local filename_tpl="ventoy-${ver_holder}-linux.tar.gz"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}-${remote_ver}
   tar xf $save_path -C $cache_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

post_enable() {
   cp -f ${metapkg_dir}/launch.sh ${installed_dir}/
   echo "==> installed '$(tilde_path ${installed_dir}/launch.sh)'"
   cp -f ${metapkg_dir}/${exec_cli} ${bins_dir}/
   echo "==> installed '$(tilde_path ${bins_dir}/${exec_cli})'"
}

post_disable() {
   if [[ -f "${bins_dir}/${exec_cli}" ]]; then
      rm -f ${bins_dir}/${exec_cli}.sh
      echo "==> removed '$(tilde_path ${bins_dir})/${exec_cli}'"
   fi
}
