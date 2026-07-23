#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="mifi/lossless-cut"
   local filename_tpl="LosslessCut-linux-x86_64.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
