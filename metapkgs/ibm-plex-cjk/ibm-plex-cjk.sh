#!/bin/bash

upk_src=$(dirname $(realpath $(which upk)))
source ${upk_src}/metapkg-pre.in

metapkg_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
pkg_id=$(basename $metapkg_dir)
cache_old=${cache_dir}/${pkg_id}.old

installed_dir=${fonts_dir}/${pkg_id}


install_pkg() {
    test_var cache_old $cache_old
    test_var installed_dir $installed_dir
    local local_ver=$(get_local_ver)
    [[ "$local_ver" == "locked" ]] && exit 0
    local base_url="https://github.com/IBM/plex/releases/download"
    local sc_name="ibm-plex-sans-sc"
    local tc_name="ibm-plex-sans-tc"
    local jp_name="ibm-plex-sans-jp"
    local kr_name="ibm-plex-sans-kr"
    local sc_url="${base_url}/%40ibm%2Fplex-sans-sc%401.1.0/${sc_name}.zip"
    local tc_url="${base_url}/%40ibm%2Fplex-sans-tc%401.1.1/${tc_name}.zip"
    local jp_url="${base_url}/%40ibm%2Fplex-sans-jp%403.0.0/${jp_name}.zip"
    local kr_url="${base_url}/%40ibm%2Fplex-sans-kr%401.1.0/${kr_name}.zip"
    test_cmd curl; test_cmd unzip
    echo "==> downloading ${sc_name}.zip ..."
    sc_dl_file=${cache_dir}/${sc_name}.zip
    if [[ -f "${sc_dl_file}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${sc_dl_file} -#L ${sc_url}
    fi
    echo "==> downloading ${tc_name}.zip ..."
    tc_dl_file=${cache_dir}/${tc_name}.zip
    if [[ -f "${tc_dl_file}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${tc_dl_file} -#L ${tc_url}
    fi
    echo "==> downloading ${jp_name}.zip ..."
    jp_dl_file=${cache_dir}/${jp_name}.zip
    if [[ -f "${jp_dl_file}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${jp_dl_file} -#L ${jp_url}
    fi
    echo "==> downloading ${kr_name}.zip ..."
    kr_dl_file=${cache_dir}/${kr_name}.zip
    if [[ -f "${kr_dl_file}" ]]; then
        echo "==> found in cache"
    else
        curl --create-dirs -o ${kr_dl_file} -#L ${kr_url}
    fi
    # backup old installed
    [[ -d $cache_old ]] && rm -r $cache_old
    [[ -d $installed_dir ]] && mv $installed_dir $cache_old
    # backup end
    unpack_dir=${cache_dir}/${pkg_id}
    mkdir -p ${unpack_dir}
    echo "==> unpacking ${sc_name}.zip ..."
    unzip -q ${sc_dl_file} -d ${unpack_dir}
    echo "==> unpacking ${tc_name}.zip ..."
    unzip -q ${tc_dl_file} -d ${unpack_dir}
    echo "==> unpacking ${jp_name}.zip ..."
    unzip -q ${jp_dl_file} -d ${unpack_dir}
    echo "==> unpacking ${kr_name}.zip ..."
    unzip -q ${kr_dl_file} -d ${unpack_dir}
    mkdir -p ${installed_dir}
    rel_path="fonts/complete/otf"
    mv ${unpack_dir}/${sc_name}/${rel_path}/hinted ${installed_dir}/${sc_name}
    echo "==> installed '$(tilde_path ${installed_dir})/${sc_name}'"
    mv ${unpack_dir}/${tc_name}/${rel_path}/hinted ${installed_dir}/${tc_name}
    echo "==> installed '$(tilde_path ${installed_dir})/${tc_name}'"
    mv ${unpack_dir}/${jp_name}/${rel_path}/hinted ${installed_dir}/${jp_name}
    echo "==> installed '$(tilde_path ${installed_dir})/${jp_name}'"
    mv ${unpack_dir}/${kr_name}/${rel_path} ${installed_dir}/${kr_name}
    echo "==> installed '$(tilde_path ${installed_dir})/${kr_name}'"
    rm -r ${unpack_dir}
    lock_pkg
}

source ${upk_src}/metapkg-post.in

