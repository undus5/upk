#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${fonts_dir}/${pkg_id}

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))

# https://www.brailleinstitute.org/freefont/
# https://braileinstitute.box.com/shared/static/waaf5z9gfss6w6tf5118im5hhlwolacc.zip

install_pkg() {
    test_cmd unzip
    unzip -q ${self_dir}/${pkg_id}.zip -d $cache_dir
    # backup old installed
    [[ -d $cache_old ]] && rm -rf $cache_old
    [[ -d $installed_dir ]] && mv $installed_dir $cache_old
    # backup end
    mv ${cache_dir}/${pkg_id} $installed_dir
    echo "==> installed '$(tilde_path $installed_dir)'"
    lock_ver
}

source ${upk_src}/metapkg-post.in

