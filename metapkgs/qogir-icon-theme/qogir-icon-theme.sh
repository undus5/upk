#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)

cache_old_1=${cache_dir}/Qogir.old
cache_old_2=${cache_dir}/Qogir-Dark.old
cache_old_3=${cache_dir}/Qogir-Light.old
installed_dir_1=${icons_dir}/Qogir
installed_dir_2=${icons_dir}/Qogir-Dark
installed_dir_3=${icons_dir}/Qogir-Light

install_pkg() {
   local repo="vinceliuice/Qogir-icon-theme"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_commit_date_sha "$repo")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path

   # backup old installed
   [[ -d $cache_old_1 ]] && rm -rf $cache_old_1
   [[ -d $cache_old_2 ]] && rm -rf $cache_old_2
   [[ -d $cache_old_3 ]] && rm -rf $cache_old_3
   [[ -d $installed_dir_1 ]] && mv $installed_dir_1 $cache_old_1
   [[ -d $installed_dir_2 ]] && mv $installed_dir_2 $cache_old_2
   [[ -d $installed_dir_3 ]] && mv $installed_dir_3 $cache_old_3
   # backup end

   local unpack_dir=${save_path%.zip}
   unzip -q $save_path -d $cache_dir
   ${unpack_dir}/install.sh --theme default
   rm -rf ${unpack_dir}
   write_ver "$remote_ver"
}

remove_pkg() {
   test_var pkg_id $pkg_id
   if [[ -d $installed_dir_1 ]]; then
      rm -rf $installed_dir_1
      echo "==> removed '$(tilde_path $installed_dir_1)'"
   fi
   if [[ -d $installed_dir_2 ]]; then
      rm -rf $installed_dir_2
      echo "==> removed '$(tilde_path $installed_dir_2)'"
   fi
   if [[ -d $installed_dir_3 ]]; then
      rm -rf $installed_dir_3
      echo "==> removed '$(tilde_path $installed_dir_3)'"
   fi
   local ver_file=${vers_dir}/${pkg_id}.txt
   if [[ -f $ver_file ]]; then
      rm -f $ver_file
      echo "==> removed '$(tilde_path $ver_file)'"
   fi
}

source ${upk_src}/includes/metapkg-post.in

