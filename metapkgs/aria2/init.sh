#!/bin/bash

cli_name="aria2.sh"

install_pkg() {
   mkdir -p $installed_dir
   cp -f ${metapkg_dir}/${cli_name} $installed_dir
   echo "==> installed '$(tilde_path ${installed_dir}/${cli_name})'"
   echo "==> 'aria2c' binary needs to be installed from distro package manager"
}

is_installed() {
   if command -v aria2c &>/dev/null; then
      echo "[installed]"
   fi
}
