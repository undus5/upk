#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${apps_dir}/${pkg_id}
exec_path=${installed_dir}/bin/zed

install_pkg() {
    test_var cache_old $cache_old
    test_var installed_dir $installed_dir
    local repo="zed-industries/zed"
    local filename_tpl="zed-linux-x86_64.tar.gz"
    local local_ver=$(get_local_ver)
    [[ "$local_ver" == "locked" ]] && exit 0
    local ver_url=$(fetch_release_ver_url "$repo" "$filename_tpl")
    local remote_ver=
    local dl_url=
    IFS="," read -r remote_ver dl_url <<< "$ver_url"
    [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]] && exit 0
    local filename=${filename_tpl/$ver_placeholder/$remote_ver}
    dl_file=${cache_dir}/${filename}
    echo "==> downloading ${filename} ..."
    if [[ -f "${dl_file}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${dl_file} -#L ${dl_url}
    fi
    # backup old installed
    [[ -d $cache_old ]] && rm -rf $cache_old
    [[ -d $installed_dir ]] && mv $installed_dir $cache_old
    # backup end
    unpack_dir=${cache_dir}/zed.app
    tar xf ${dl_file} -C ${cache_dir}
    mv ${unpack_dir} ${installed_dir}
    echo "==> installed '$(tilde_path $installed_dir)'"
    write_ver "$remote_ver"
}

source ${upk_src}/metapkg-post.in

