#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/waterfox

install_pkg() {
    self_update_pkg_info "https://www.torproject.org/download/"
    exit 1
}

source ${upk_src}/metapkg-post.in

