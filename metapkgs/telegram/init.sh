#!/bin/bash

exec_path=${installed_dir}/Telegram

install_pkg() {
   local repo="telegramdesktop/tdesktop"
   local filename_tpl="tsetup.${ver_holder}.tar.xz"

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

   unpack_dir=${cache_dir}/Telegram
   tar xf $save_path -C $cache_dir
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   lock_ver
}

post_enable() {
   echo "==> run 'upk launch telegram' to start app for the first time"
   echo "==> it will create desktop entry automatically"
   echo "==> next time you could start from desktop entry"
}
