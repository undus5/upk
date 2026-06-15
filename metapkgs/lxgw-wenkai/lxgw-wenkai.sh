#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${fonts_dir}/${pkg_id}

install_pkg() {
   local repo="lxgw/LxgwWenKai"
   local filename_tpl="LXGWWenKai-Regular.ttf"

   printf "==> checking update for $pkg_id ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   local filename_1=$filename_tpl
   local filename_2=${filename_tpl/Regular/Medium}
   local filename_3=${filename_tpl/Regular/Light}
   local dl_url_1=$dl_url
   local dl_url_2=${dl_url/Regular/Medium}
   local dl_url_3=${dl_url/Regular/Light}
   local save_path_1=${cache_dir}/${filename_1}
   local save_path_2=${cache_dir}/${filename_2}
   local save_path_3=${cache_dir}/${filename_3}
   download_file $dl_url_1 $save_path_1
   download_file $dl_url_2 $save_path_2
   download_file $dl_url_3 $save_path_3
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p $unpack_dir
   cp $save_path_1 ${unpack_dir}/
   cp $save_path_2 ${unpack_dir}/
   cp $save_path_3 ${unpack_dir}/
   mv $unpack_dir $installed_dir
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

source ${upk_src}/includes/metapkg-post.in

