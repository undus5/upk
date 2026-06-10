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
    local repo="JetBrains/JetBrainsMono"
    local filename_tpl="JetBrainsMono-${ver_placeholder}.zip"
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
    unpack_dir=${dl_file%.*}
    mkdir -p $unpack_dir
    echo "==> unpacking ${filename} ..."
    unzip -q $dl_file -d $unpack_dir
    mkdir -p $installed_dir
    mv ${unpack_dir}/fonts/ttf/JetBrainsMonoNL*.ttf ${installed_dir}/
    rm -rf $unpack_dir
    echo "==> installed '$(tilde_path $installed_dir)'"
    write_ver "$remote_ver"
}

source ${upk_src}/includes/metapkg-post.in

