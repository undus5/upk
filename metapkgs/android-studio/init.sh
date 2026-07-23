#!/bin/bash

exec_path=${installed_dir}/bin/studio

install_pkg() {
   test_var pkg_id $pkg_id
   local local_ver=$(get_local_ver)
   if [[ "$local_ver" == "locked" ]]; then
      echo "==> '$pkg_id' already updated"
      exit 0   # prevent enable_entry(), post_enable()
   fi
   printf "==> ${pkg_id} not support auto installation  \n"
   printf "==> 1. download from: https://developer.android.com/studio\n"
   printf "==> 2. put into '$(tilde_path $installed_dir)'\n"
   printf "==> 3. enable desktop entry\n"
   printf "==> 4. lock package (to mark package as installed)\n"
   exit 0   # prevent enable_entry(), post_enable()
}
