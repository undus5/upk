#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/VentoyGUI.x86_64
exec_cli=ventoy-cli.sh

install_pkg() {
   local repo="ventoy/Ventoy"
   local filename_tpl="ventoy-${ver_placeholder}-linux.tar.gz"

   printf "==> checking update for $pkg_id ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file $dl_url $save_path
   backup_old_installed

   unpack_dir=${cache_dir}/${pkg_id}-${remote_ver}
   tar xf ${save_path} -C ${cache_dir}
   mv ${unpack_dir} ${installed_dir}
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

post_enable() {
   sed -i "s#VENTOY_DIR#${installed_dir}#" ${entries_dir}/${pkg_id}.desktop
   cp -f ${metapkg_dir}/${exec_cli} ${bins_dir}
   echo "==> installed '$(tilde_path ${bins_dir})/${exec_cli}'"
}

post_disable() {
   if [[ -f "${bins_dir}/${exec_cli}" ]]; then
      rm -f ${bins_dir}/${exec_cli}.sh
      echo "==> removed '$(tilde_path ${bins_dir})/${exec_cli}'"
   fi
}

source ${upk_src}/includes/metapkg-post.in

