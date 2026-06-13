#!/bin/bash

sandbox_dir="${1}"
exec_path="${2}"
home_dir=$(realpath ~)

errf() { printf "${@}\n" >&2; exit 1; }
get_help() { echo "Usage: $(basename $0) <sandbox_dir> <exec_path>"; }

[[ -z "$sandbox_dir" || -z "$exec_path" ]] && get_help && exit 1
[[ -d "$sandbox_dir" ]] || errf "directory not found: ${sandbox_dir}"

binds_or_links=
if [[ -L /bin ]]; then
   binds_or_links+=" --symlink $(realpath /bin) /bin"
else
   binds_or_links+=" --ro-bind /bin /bin"
fi
if [[ -L /lib ]]; then
   binds_or_links+=" --symlink $(realpath /lib) /lib"
else
   binds_or_links+=" --ro-bind /lib /lib"
fi
if [[ -L /lib64 ]]; then
   binds_or_links+=" --symlink $(realpath /lib64) /lib64"
else
   binds_or_links+=" --ro-bind /lib64 /lib64"
fi

bwrap \
   --ro-bind /etc /etc \
   --ro-bind /sys /sys \
   --ro-bind /usr /usr \
   --dev /dev \
   --dev-bind /dev/dri /dev/dri \
   --proc /proc \
   --tmpfs /tmp \
   --unshare-all \
   --share-net \
   --bind $sandbox_dir $home_dir \
   $binds_or_links $exec_path

