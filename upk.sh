#!/bin/bash

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
proj_dir=$self_dir
source ${proj_dir}/header.sh
# import $UPK_METAPKG_DIR
if [[ -f ${data_dir}/env.sh ]]; then
   source ${data_dir}/env.sh
fi

(( EUID != 0 )) || errf "==> abort for superuser"

get_help() {
   printf "Usage: $(basename ${0}) <action> [app_id]\n"
   printf "   list                             : list available packages\n"
   printf "   install|remove <app_id[s]> [-y]  : -y skip confirmation\n"
   printf "   update         [app_id[s]] [-y]  : empty app_id means update all\n"
   printf "   enable|disable <app_id>          : enable/disable desktop entry and icon\n"
   printf "   lock           <app_id>          : prevent update and mark installed\n"
   printf "   clean          [old]             : clean cache\n"
   printf "   -h|--help\n"
}

list_metapkgs() {
   local ids1=
   local ids2=
   local pkg_ids=
   if [[ -n "$UPK_METAPKG_DIR" && -d $UPK_METAPKG_DIR ]]; then
      mapfile -t ids1 < <(ls -1 ${UPK_METAPKG_DIR}/)
   fi
   mapfile -t ids2 < <(ls -1 ${self_dir}/metapkgs/)
   mapfile -t pkg_ids < <(printf "%s\n" "${ids1[@]}" "${ids2[@]}" | sort -u)
   local max_len=0
   local curr_len=0
   for pkg_id in "${pkg_ids[@]}"; do
      curr_len=${#pkg_id}
         (( curr_len > max_len )) && max_len=$curr_len
      done
      for pkg_id in "${pkg_ids[@]}"; do
         printf "%-${max_len}s" "$pkg_id"
         if [[ -f "${vers_dir}/${pkg_id}.txt" ]]; then
            printf "  [installed]"
         fi
         printf "\n"
      done
}

clean_cache() {
   test_var cache_dir $cache_dir
   [[ -d "${cache_dir}" ]] || errf "directory not found: ${cache_dir}"
   if [[ "$1" == old ]]; then
      rm -rf ${cache_dir}/*.old
      echo "==> cleaned $(tilde_path $cache_dir)/*.old"
   else
      rm -rf ${cache_dir}/*
      echo "==> cleaned $(tilde_path $cache_dir)/"
   fi
}

get_confirmation() {
   local prompt="$1"; shift
   local skip_flag="$1"; shift
   local pkg_ids=("$@")
   local confirmation=
   if [[ "$skip_flag" != "-y" ]]; then
      printf "Selected packages:\n"
      for id in "${pkg_ids[@]}"; do
         printf " $id"
      done
      printf "\n"
      read -r -p "${prompt^}" confirmation
   else
      confirmation=y
   fi
   [[ "${confirmation}" =~ ^[yY]$ ]] || exit 1
}

update_installed() {
   local skip_confirm="$1"
   local pkg_ids=()
   local txts
   local tname
   local ver
   mapfile -t txts < <(ls -1 ${vers_dir}/*.txt)
   for t in "${txts[@]}"; do
      tname=$(basename $t)
      pkg_id=${tname%.*}
      ver=$(get_local_ver "$pkg_id")
      if [[ "$ver" != "locked" ]]; then
         pkg_ids+=("$pkg_id")
      fi
   done
   if [[ "${#pkg_ids[@]}" == "0" ]]; then
      echo "==> packages already updated"; exit 0
   fi
   local prompt="Check and update packages? [y/N]: "
   get_confirmation "$prompt" "$skip_confirm" "${pkg_ids[@]}"
   local pkg_id
   local metapkg_dir
   for pkg_id in "${pkg_ids[@]}"; do
      metapkg_dir=$(get_metapkg_dir $pkg_id)
      [[ -n "$metapkg_dir" ]] || errf "metapkg not found: $pkg_id"
      ${proj_dir}/metapkg.sh $pkg_id update "$@"
   done
}

sub_cmd="$1"; shift
case "$sub_cmd" in
   install|update|remove|enable|disable|lock|unlock)
      skip_confirm=false
      case $sub_cmd in
         enable|disable|lock|unlock)
            skip_confirm="-y"
            ;;
      esac
      if [[ "$sub_cmd" == "update" ]]; then
         if [[ -z "$@" ]]; then
            update_installed; exit 0
         elif [[ "$1" == "-y" ]]; then
            skip_confirm="-y"; shift
            if [[ -z "$@" ]]; then
               update_installed -y; exit 0
            fi
         fi
      fi
      pkg_ids=()
      for pkg_id in "$@"; do
         arg=${pkg_id%/}
         if [[ "$pkg_id" == "-y" ]]; then
            skip_confirm="-y"
         else
            metapkg_dir=$(get_metapkg_dir $pkg_id)
            [[ -n "$metapkg_dir" ]] || errf "metapkg not found: $pkg_id"
            pkg_ids+=("$arg")
         fi
      done
      prompt="$sub_cmd packages? [y/N]: "
      get_confirmation "$prompt" "$skip_confirm" "${pkg_ids[@]}"
      for pkg_id in "${pkg_ids[@]}"; do
         ${proj_dir}/metapkg.sh $pkg_id $sub_cmd
      done
      ;;
   launch)
      pkg_id=${1%/}; shift
      metapkg_dir=$(get_metapkg_dir $pkg_id)
      [[ -n "$metapkg_dir" ]] || errf "metapkg not found: $pkg_id"
      ${proj_dir}/metapkg.sh $pkg_id $sub_cmd "$@"
      ;;
   list)
      list_metapkgs
      ;;
   clean)
      clean_cache $@
      ;;
   ""|-h|--help)
      get_help
      ;;
   *)
      get_help; exit 1
      ;;
esac
