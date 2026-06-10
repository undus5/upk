#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/includes/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${fonts_dir}/${pkg_id}

install_pkg() {
    test_var cache_old $cache_old
    test_var installed_dir $installed_dir
    local repo="lxgw/LxgwWenKai"
    local filename_tpl="LXGWWenKai-Regular.ttf"
    local local_ver=$(get_local_ver)
    [[ "$local_ver" == "locked" ]] && exit 0
    local ver_url=$(fetch_release_ver_url "$repo" "$filename_tpl")
    local remote_ver=
    local dl_url=
    IFS="," read -r remote_ver dl_url <<< "$ver_url"
    [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]] && exit 0
    local filename_1=$filename_tpl
    local filename_2=${filename_tpl/Regular/Medium}
    local filename_3=${filename_tpl/Regular/Light}
    local dl_url_1=$dl_url
    local dl_url_2=${dl_url/Regular/Medium}
    local dl_url_3=${dl_url/Regular/Light}
    local dl_file_1=${cache_dir}/${filename_1}
    local dl_file_2=${cache_dir}/${filename_2}
    local dl_file_3=${cache_dir}/${filename_3}
    echo "==> downloading ${filename_1} ..."
    if [[ -f "${dl_file_1}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${dl_file_1} -#L ${dl_url_1}
    fi
    echo "==> downloading ${filename_2} ..."
    if [[ -f "${dl_file_2}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${dl_file_2} -#L ${dl_url_2}
    fi
    echo "==> downloading ${filename_3} ..."
    if [[ -f "${dl_file_3}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${dl_file_3} -#L ${dl_url_3}
    fi
    # backup old installed
    [[ -d $cache_old ]] && rm -rf $cache_old
    [[ -d $installed_dir ]] && mv $installed_dir $cache_old
    # backup end
    unpack_dir=${cache_dir}/${pkg_id}
    mkdir -p $unpack_dir
    cp $dl_file_1 ${unpack_dir}/
    cp $dl_file_2 ${unpack_dir}/
    cp $dl_file_3 ${unpack_dir}/
    mv $unpack_dir $installed_dir
    echo "==> installed '$(tilde_path $installed_dir)'"
    write_ver "$remote_ver"
}

source ${upk_src}/includes/metapkg-post.in

