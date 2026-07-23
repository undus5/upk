#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="imputnet/helium-linux"
   local filename_tpl="helium-${ver_holder}-x86_64.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
