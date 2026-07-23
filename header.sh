#!/bin/bash

set -e

data_dir=~/upk.d
[[ -d ${data_dir} ]] || mkdir -p ${data_dir}

apps_dir=$data_dir/apps
bins_dir=$data_dir/bins
vers_dir=$data_dir/vers
cache_dir=$data_dir/cache

[[ -d $apps_dir ]] || mkdir -p $apps_dir
[[ -d $bins_dir ]] || mkdir -p $bins_dir
[[ -d $vers_dir ]] || mkdir -p $vers_dir
[[ -d $cache_dir ]] || mkdir -p $cache_dir

entries_dir=~/.local/share/applications
icons_dir=~/.icons

[[ -d $entries_dir ]] || mkdir -p $entries_dir
[[ -d $icons_dir ]] || mkdir -p $icons_dir

fonts_dir=~/.local/share/fonts

[[ -d $fonts_dir ]] || mkdir -p $fonts_dir

ver_holder="_VERSION_"
exec_holder="_EXEC_"

# helper functions
errf() { printf "$@\n" >&2; exit 1; }
rtnf() { printf "$@\n"; exit 0; }
test_cmd() { command -v $1 &>/dev/null || errf "command not found: $@"; }
test_var() { [[ -n "$2" ]] || errf "undefined var: $1"; }
# replace '/home/*' with '~' in path for display
tilde_path() { echo "$1" | sed "s#$(realpath ~)#~#"; }

get_local_ver() {
   if [[ -n "$1" ]]; then
      pkg_id="$1"
   fi
   test_var pkg_id ${pkg_id}
   local ver_file=${vers_dir}/${pkg_id}.txt
   if [[ -f "${ver_file}" ]]; then
      cat ${ver_file}
   fi
}

get_metapkg_dir() {
   local pkg_id="$1"
   if [[ -z "$pkg_id" ]]; then
      echo ""
   else
      local pkg_dir
      local test_dir
      if [[ -n "$UPK_METAPKG_DIR" && -d $UPK_METAPKG_DIR ]]; then
         test_dir=${UPK_METAPKG_DIR}/${pkg_id}
         if [[ -d $test_dir ]]; then
            pkg_dir=$test_dir
         fi
      fi
      if [[ ! -d $pkg_dir ]]; then
         test_dir=${self_dir}/metapkgs/${pkg_id}
         if [[ -d $test_dir ]]; then
            pkg_dir=$test_dir
         fi
      fi
      if [[ -d $pkg_dir ]]; then
         echo $pkg_dir
      fi
   fi
}
