#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/bin/studio

install_pkg() {
    test_var pkg_id $pkg_id
    printf "==> ${pkg_id} not support auto installation  \n"
    printf "==> 1. download from: https://developer.android.com/studio\n"
    printf "==> 2. put into '$(tilde_path $installed_dir)'\n"
    printf "==> 3. enable desktop entry\n"
    printf "==> 4. lock package (to mark package as installed)\n"
    exit 1
}

source ${upk_src}/includes/metapkg-post.in

