#!/bin/bash

exec_path=${installed_dir}/bin/studio

install_pkg() {
   local local_ver=$(get_local_ver)
   printf "==> ${pkg_id} not support auto installation\n"
   printf "==> 1. download from: https://developer.android.com/studio\n"
   printf "==> 2. put into '$(tilde_path $installed_dir)'\n"
   printf "==> 3. enable desktop entry\n"
   printf "==> 4. lock package (to mark package as installed)\n"
   exit 0   # prevent enable_entry(), post_enable()
}
