#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)

cache_old_1=${cache_dir}/Qogir.old
cache_old_2=${cache_dir}/Qogir-Dark.old
cache_old_3=${cache_dir}/Qogir-Light.old
installed_dir_1=${icons_dir}/Qogir
installed_dir_2=${icons_dir}/Qogir-Dark
installed_dir_3=${icons_dir}/Qogir-Light

install_pkg() {
    local repo="vinceliuice/Qogir-icon-theme"
    local local_ver=$(get_local_ver)
    [[ "$local_ver" == "locked" ]] && exit 0
    local date_sha=$(fetch_commit_date_sha "$repo")
    local remote_ver=
    local sha=
    IFS="," read -r remote_ver sha <<< "$date_sha"
    [[ -z "$(compare_date_vers $remote_ver $local_ver)" ]] && exit 0
    local dl_url="https://github.com/${repo}/archive/${sha}.zip"
    local filename=Qogir-icon-theme-${sha}.zip
    dl_file=${cache_dir}/${filename}
    echo "==> downloading ${filename} ..."
    if [[ -f "${dl_file}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${dl_file} -#L ${dl_url}
    fi
    # backup old installed
    [[ -d $cache_old_1 ]] && rm -rf $cache_old_1
    [[ -d $cache_old_2 ]] && rm -rf $cache_old_2
    [[ -d $cache_old_3 ]] && rm -rf $cache_old_3
    [[ -d $installed_dir_1 ]] && mv $installed_dir_1 $cache_old_1
    [[ -d $installed_dir_2 ]] && mv $installed_dir_2 $cache_old_2
    [[ -d $installed_dir_3 ]] && mv $installed_dir_3 $cache_old_3
    # backup end
    local unpack_dir=${dl_file%.zip}
    unzip -q $dl_file -d $cache_dir
    ${unpack_dir}/install.sh --theme default
    rm -rf ${unpack_dir}
    write_ver "$remote_ver"
}

remove_pkg() {
    test_var pkg_id $pkg_id
    if [[ -d $installed_dir_1 ]]; then
        rm -rf $installed_dir_1
        echo "==> removed '$(tilde_path $installed_dir_1)'"
    fi
    if [[ -d $installed_dir_2 ]]; then
        rm -rf $installed_dir_2
        echo "==> removed '$(tilde_path $installed_dir_2)'"
    fi
    if [[ -d $installed_dir_3 ]]; then
        rm -rf $installed_dir_3
        echo "==> removed '$(tilde_path $installed_dir_3)'"
    fi
    local ver_file=${vers_dir}/${pkg_id}.txt
    if [[ -f $ver_file ]]; then
        rm $ver_file
        echo "==> removed '$(tilde_path $ver_file)'"
    fi
}

source ${upk_src}/metapkg-post.in

