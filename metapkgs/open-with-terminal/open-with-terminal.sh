#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
    local repo="localsend/localsend"
    local filename_tpl="LocalSend-${ver_placeholder}-linux-x86-64.AppImage"
    install_release_appimage "$repo" "$filename_tpl"
}

exec_name=open-terminal-here.sh
exec_path=${installed_dir}/${exec_name}
xdg_exec=${bins_dir}/xdg-terminal-exec

install_pkg() {
    test_var installed_dir $installed_dir
    test_var exec_name $exec_name
    mkdir -p $installed_dir
    self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
    cp -f ${self_dir}/${exec_name} ${installed_dir}/
    echo "==> installed '$(tilde_path ${installed_dir})/${exec_name}'"
    lock_ver
}

remove_pkg() {
    test_var pkg_id $pkg_id
    test_var installed_dir $installed_dir
    if [[ -d $installed_dir ]]; then
        rm -rf $installed_dir
        echo "==> removed '$(tilde_path $installed_dir)'"
    fi
    local ver_file=${vers_dir}/${pkg_id}.txt
    if [[ -f $ver_file ]]; then
        rm $ver_file
        echo "==> removed '$(tilde_path $ver_file)'"
    fi
}

post_enable() {
    ln -sf ${installed_dir}/${exec_name} $xdg_exec
    echo "==> installed '$(tilde_path $xdg_exec)'"
}

post_disable() {
    if [[ -e $xdg_exec ]]; then
        rm $xdg_exec
        echo "==> removed '$(tilde_path $xdg_exec)'"
    fi
}

source ${upk_src}/includes/metapkg-post.in

