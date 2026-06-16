#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${fonts_dir}/${pkg_id}

install_pkg() {
   local repo="be5invis/Sarasa-Gothic"
   local filename_tpl="SarasaTerm-TTF-${ver_placeholder}.7z"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   echo "==> unpacking ${filename} ..."
   unpack_dir=${cache_dir}/${pkg_id}
   mkdir -p ${unpack_dir}
   7z x ${save_path} -o${unpack_dir} >/dev/null
   rm -f ${unpack_dir}/SarasaTermCL*.ttf
   rm -f ${unpack_dir}/SarasaTermHC*.ttf
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

source ${upk_src}/includes/metapkg-post.in

