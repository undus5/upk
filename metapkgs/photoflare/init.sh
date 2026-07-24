#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="PhotoFlare/photoflare"
   local filename_tpl="PhotoFlare-v1.7.2-2-x86_64.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
