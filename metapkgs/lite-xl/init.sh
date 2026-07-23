#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="lite-xl/lite-xl"
   local filename_tpl="LiteXL-v${ver_holder}-addons-x86_64.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
