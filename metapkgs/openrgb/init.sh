#!/bin/bash

exec_path="${installed_dir}/openrgb.AppImage"
cli_name="$pkg_id"

install_pkg() {
   local local_ver=$(get_local_ver)
   printf "==> ${pkg_id} releases do not follow consistent pattern"
   printf ", install manually\n"
   printf "==> 1. download AppImage from:"
   printf " https://github.com/CalcProgrammer1/OpenRGB/releases/\n"
   printf "==> 2. put into '$(tilde_path ${exec_path})'\n"
   printf "==> 3. enable desktop entry\n"
   printf "==> 4. lock package (to mark package as installed)\n"
   printf "==> 5. download '60-openrgb.rules', put into '/etc/udev/rules.d/'\n"
   printf "==> 6. run 'udevadm control --reload-rules' and 'udevadm trigger'\n"
   exit 0   # prevent enable_entry(), post_enable()
}
