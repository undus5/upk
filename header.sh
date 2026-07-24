#!/bin/bash

set -e

data_dir=~/upk.d
if [[ ! -d ${data_dir} ]]; then
   mkdir -p ${data_dir}
fi

apps_dir=$data_dir/apps
bins_dir=$data_dir/bins
vers_dir=$data_dir/vers
cache_dir=$data_dir/cache
runs_dir=$data_dir/runs

if [[ ! -d $apps_dir ]]; then
   mkdir -p $apps_dir
fi
if [[ ! -d $bins_dir ]]; then
   mkdir -p $bins_dir
fi
if [[ ! -d $vers_dir ]]; then
   mkdir -p $vers_dir
fi
if [[ ! -d $cache_dir ]]; then
   mkdir -p $cache_dir
fi
if [[ ! -d $runs_dir ]]; then
   mkdir -p $runs_dir
fi

entries_dir=~/.local/share/applications
icons_dir=~/.icons

if [[ ! -d $entries_dir ]]; then
   mkdir -p $entries_dir
fi
if [[ ! -d $icons_dir ]]; then
   mkdir -p $icons_dir
fi

fonts_dir=~/.local/share/fonts

if [[ ! -d $fonts_dir ]]; then
   mkdir -p $fonts_dir
fi

ver_holder="_VERSION_"
exec_holder="_EXEC_"

# helper functions
errf() { printf "$@\n" >&2; exit 1; }
rtnf() { printf "$@\n"; exit 0; }
test_cmd() { command -v $1 &>/dev/null || errf "command not found: $@"; }
test_var() {
   if [[ -z "$2" ]]; then
      errf "undefined var: $1"
   fi
}
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
