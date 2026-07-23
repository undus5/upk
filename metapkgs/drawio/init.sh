#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="jgraph/drawio-desktop"
   local filename_tpl="drawio-x86_64-${ver_holder}.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
