#!/bin/bash

installed_dir=${fonts_dir}/${pkg_id}

install_pkg() {
   local repo="ryanoasis/nerd-fonts"
   local filename_tpl="JetBrainsMono.tar.xz"

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

   unpack_dir=${save_path%.tar.xz}Nerd
   mkdir -p $unpack_dir
   tar xf $save_path -C $unpack_dir
   mkdir -p $installed_dir
   mv ${unpack_dir}/JetBrainsMonoNL*.ttf ${installed_dir}/
   fc-cache -f
   rm -rf $unpack_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

is_enabled() {
   if [[ -n "$(is_installed)" ]]; then
      echo "[enabled]"
   fi
}
