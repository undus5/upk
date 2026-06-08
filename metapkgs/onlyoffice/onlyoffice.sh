#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
    local repo="ONLYOFFICE/DesktopEditors"
    local filename_tpl="DesktopEditors-x86_64.AppImage"
    install_release_appimage "$repo" "$filename_tpl"
}

source ${upk_src}/metapkg-post.in

