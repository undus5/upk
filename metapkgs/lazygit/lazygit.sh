#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}

install_pkg() {
   local repo="jesseduffield/lazygit"
   local filename_tpl="lazygit_${ver_placeholder}_linux_x86_64.tar.gz"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   [[ -n "$path_url" ]] && printf "\n" || rtnf "up to date"
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
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
   ln -sf ${installed_dir}/lazygit ${bins_dir}/
   echo "==> linked '$(tilde_path ${bins_dir}/lazygit)'"
}

post_disable() {
   local l=${bins_dir}/lazygit
   if [[ -L $l ]]; then
      rm -f $l
      echo "==> removed '$(tilde_path $l)'"
   fi
}

source ${upk_src}/includes/metapkg-post.in
