#!/bin/bash

exec_path=${installed_dir}/${pkg_id}.AppImage

install_pkg() {
   local repo="obsidianmd/obsidian-releases"
   local filename_tpl="Obsidian-${ver_holder}.AppImage"
   install_release_appimage "$repo" "$filename_tpl"
}
