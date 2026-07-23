#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="localsend/localsend"
   local filename_tpl="LocalSend-${ver_holder}-linux-x86-64.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
