#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="koreader/koreader"
   local filename_tpl="koreader-v${ver_holder}-x86_64.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
