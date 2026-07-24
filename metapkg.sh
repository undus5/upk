#!/bin/bash

self_dir=$(dirname $(realpath ${BASH_SOURCE[0]}))
proj_dir=$self_dir
source ${proj_dir}/header.sh

################################################################################

install_pkg() { return; }
post_enable() { return; }
post_disable() { return; }
is_installed() {
   if [[ -f ${vers_dir}/${pkg_id}.txt ]]; then
      echo "[installed]"
   fi
}
is_enabled() {
   local entry_file=$(find $metapkg_dir -mindepth 1 -maxdepth 1 -type f -name "*.desktop" | head -n 1)
   if [[ -f $entry_file ]]; then
      local filename=$(basename $entry_file)
      if [[ -n "$filename" && -f ~/.local/share/applications/${filename} ]]; then
         echo "[enabled]"
      fi
   fi
}
post_disable_cli() {
   if [[ -n "$exec_name" ]]; then
      local f=${bins_dir}/${exec_name}
      if [[ -f $f ]]; then
         rm -f $f
         echo "==> removed '$(tilde_path $f)'"
      fi
   fi
}
is_enabled_cli() {
   if [[ -n "$exec_name" && -f ${bins_dir}/${exec_name} ]]; then
      echo "[enabled]"
   fi
}

pkg_id="$1"
if [[ -n "$pkg_id" ]]; then
   shift
fi
sub_cmd="$1"
if [[ -n "$sub_cmd" ]]; then
   shift
fi

cache_old=${cache_dir}/${pkg_id}.old
installed_dir=${apps_dir}/${pkg_id}
# exec_path=${installed_dir}/...

metapkg_dir=$(get_metapkg_dir $pkg_id)
if [[ -z "$metapkg_dir" ]]; then
   errf "==> metapkg not found: $pkg_id"
fi
source ${metapkg_dir}/init.sh

################################################################################

jq_dl_filter() {
   local filename_tpl="$1"
   local ver="$2"
   local regex=${filename_tpl/${ver_holder}/${ver}\\\\S*}
   local filter=".assets|map(select(.name|test(\"${regex}\";\"n\"))).[0]"
   filter+=".browser_download_url"
   echo $filter
}

# get latest release info from github api
# return joined string "ver,url"
fetch_release_ver_url() {
   local repo="$1"
   local filename_tpl="$2"
   if [[ -z "$repo" ]]; then
      errf "==> undefined var: repo"
   fi
   if [[ -z "$filename_tpl" ]]; then
      errf "==> undefined var: filename_tpl"
   fi
   local json_tmpfile=$(mktemp)
   local api_url="https://api.github.com/repos/${repo}/releases/latest"
   test_cmd curl; test_cmd jq
   curl -sL $api_url > $json_tmpfile
   local ver=$(cat $json_tmpfile | jq -r '.tag_name|ltrimstr("v")')
   local url=$(cat $json_tmpfile | jq -r "$(jq_dl_filter $filename_tpl $ver)")
   echo "${ver},${url}"
   rm -f $json_tmpfile
}

# return joined string "ver,url,save_path" if need downloading
test_release_ver_url() {
   local repo="$1"
   local filename_tpl="$2"
   local local_ver=$(get_local_ver)
   if [[ "$local_ver" == "locked" ]]; then
      exit 0
   fi
   local ver_url=$(fetch_release_ver_url "$repo" "$filename_tpl")
   local remote_ver=
   local dl_url=
   IFS="," read -r remote_ver dl_url <<< "$ver_url"
   if [[ -z "$(compare_dot_vers $remote_ver $local_ver)" ]]; then
      exit 0
   fi
   local filename=${filename_tpl/$ver_holder/$remote_ver}
   local save_path=${cache_dir}/${filename}
   echo "${remote_ver},${dl_url},${save_path}"
}

download_file() {
   local dl_url="$1"
   local save_path="$2"
   echo "==> downloading '$(basename $save_path)' ..."
   if [[ -f "${save_path}" ]]; then
      echo "==> found in cache"
   else
      curl --create-dirs -o ${save_path} -#L ${dl_url}
   fi
}

backup_old_installed() {
   if [[ -d $cache_old ]]; then
      rm -rf $cache_old
   fi
   if [[ -d $installed_dir ]]; then
      mv $installed_dir $cache_old
   fi
}

install_release_appimage() {
   test_var pkg_id $pkg_id
   local repo="$1"
   local filename_tpl="$2"

   printf "==> checking update for '$pkg_id' ... "
   local path_url=$(test_release_ver_url "$repo" "$filename_tpl")
   if [[ -n "$path_url" ]]; then
      printf "\n"
   else
      rtnf "up to date"
   fi
   IFS="," read -r remote_ver dl_url save_path <<< "$path_url"
   download_file "$dl_url" "$save_path"
   backup_old_installed

   mkdir -p $installed_dir
   chmod u+x $save_path
   cp $save_path $exec_path
   echo "==> installed '$(tilde_path $installed_dir)'"
   write_ver "$remote_ver"
}

# compare versions like a[.b.c.d...]
# return remote_ver or blank, blank means no need to update
compare_dot_vers() {
   local remote_ver="$1"
   local ver_pattern="^[0-9]+(.[0-9]+)*$"
   if [[ ! "$remote_ver" =~ $ver_pattern ]]; then
      errf "==> invalid remote_ver"
   fi
   local local_ver="$2"
   local result=""
   local rvers=
   local lvers=
   local rver=
   local lver=
   if [[ -z "$local_ver" ]]; then
      result=$remote_ver
   else
      if [[ ! "$local_ver" =~ $ver_pattern ]]; then
         errf "==> invalid local_ver"
      fi
      IFS="." read -r -a rvers <<< "$remote_ver"
      IFS="." read -r -a lvers <<< "$local_ver"
      for i in "${!rvers[@]}"; do
         rver=${rvers[i]}
         lver=${lvers[i]}
         if (( rver > lver )); then
            result=$remote_ver
            break
         fi
      done
   fi
   echo $result
}

# return latest "commit_date,commit_sha"
fetch_commit_date_sha() {
   local repo="$1"
   if [[ -z "$repo" ]]; then
      errf "==> undefined var: repo"
   fi
   local api_url="https://api.github.com/repos/${repo}/commits"
   test_cmd curl; test_cmd jq
   curl -sL $api_url | jq -r '.[0]|"\(.commit.author.date),\(.sha)"'
}

# return joined string "ver,url,save_path" if need downloading
test_commit_date_sha() {
   local repo="$1"
   local local_ver=$(get_local_ver)
   if [[ "$local_ver" == "locked" ]]; then
      exit 0
   fi
   local date_sha=$(fetch_commit_date_sha "$repo")
   local remote_ver=
   local sha=
   IFS="," read -r remote_ver sha <<< "$date_sha"
   if [[ -z "$(compare_date_vers $remote_ver $local_ver)" ]]; then
      exit 0
   fi
   local dl_url="https://github.com/${repo}/archive/${sha}.zip"
   local repo_author=
   local repo_name=
   IFS="/" read -r repo_author repo_name <<< "$date_sha"
   local filename=${repo_name}-${sha}.zip
   save_path=${cache_dir}/${filename}
   echo "${remote_ver},${dl_url},${save_path}"
}

compare_date_vers() {
   local remote_date="$1"
   local local_date="$2"
   if [[ -z "$remote_ver" ]]; then
      errf "undefined var: ${remote_date}"
   fi
   local remote_ts=
   local local_ts=
   if [[ -z "$local_date" ]]; then
      echo $remote_date
   else
      remote_ts=$(date -d ${remote_date} +%s)
      local_ts=$(date -d ${local_date} +%s)
      (( remote_ts > local_ts )) && echo $remote_date
   fi
}

remove_pkg() {
   test_var pkg_id $pkg_id
   test_var installed_dir $installed_dir
   if [[ -d $installed_dir ]]; then
      rm -rf $installed_dir
      echo "==> removed '$(tilde_path $installed_dir)'"
   fi
   local ver_file=${vers_dir}/${pkg_id}.txt
   if [[ -f $ver_file ]]; then
      rm -f $ver_file
      echo "==> removed '$(tilde_path $ver_file)'"
   fi
}

# copy desktop entries and icons
enable_entry() {
   test_var metapkg_dir $metapkg_dir
   local files
   local dest
   mapfile -t files < <(find $metapkg_dir -mindepth 1 -maxdepth 1 -type f \
      -name "*.desktop")
   for f in ${files[@]}; do
      dest=${entries_dir}/$(basename $f)
      if [[ "$exec_path" =~ [[:space:]] ]]; then
         exec_path=\"$exec_path\"
      fi
      sed "s#${exec_holder}#${exec_path}#" $f > ${dest}
      echo "==> installed '$(tilde_path ${dest})'"
   done
   update-desktop-database ${entries_dir}
   mapfile -t files < <(find $metapkg_dir -mindepth 1 -maxdepth 1 -type f \
      -name "*.png")
   for f in ${files[@]}; do
      cp -f $f ${icons_dir}/
      echo "==> installed '$(tilde_path ${icons_dir}/$(basename $f))'"
   done
}

# remove desktop entries and icons
disable_entry() {
   test_var metapkg_dir $metapkg_dir
   local files=
   mapfile -t files < <(find $metapkg_dir -mindepth 1 -maxdepth 1 -type f \
      -name "*.desktop")
   for f in ${files[@]}; do
      ff=${entries_dir}/$(basename $f)
      if [[ -f $ff ]]; then
         rm -f $ff
         echo "==> removed '$(tilde_path $ff)'"
      fi
   done
   update-desktop-database ${entries_dir}
   mapfile -t files < <(find $metapkg_dir -mindepth 1 -maxdepth 1 -type f \
      -name "*.png")
   for f in ${files[@]}; do
      ff=${icons_dir}/$(basename $f)
      if [[ -f $ff ]]; then
         rm -f $ff
         echo "==> removed '$(tilde_path $ff)'"
      fi
   done
}

write_ver() {
   test_var pkg_id $pkg_id
   local ver="$1"
   local ver_file=${vers_dir}/${pkg_id}.txt
   echo "$ver" > $ver_file
   echo "==> wrote '$ver' to '$(tilde_path $ver_file)'"
}

lock_ver() {
   write_ver "locked" "$pkg_id"
}

unlock_ver() {
   write_ver "" "$pkg_id"
}

launch_pkg() {
   test_var exec_path $exec_path
   if [[ ! -x $exec_path ]]; then
      errf "==> not executable : $exec_path"
   fi
   "$exec_path" "$@"
}

################################################################################

case "$sub_cmd" in
   install)
      install_pkg
      enable_entry
      post_enable
      ;;
   update)
      install_pkg
      ;;
   enable)
      enable_entry
      post_enable
      ;;
   disable)
      disable_entry
      post_disable
      ;;
   remove)
      remove_pkg
      disable_entry
      post_disable
      ;;
   lock)
      lock_ver
      ;;
   unlock)
      unlock_ver
      ;;
   launch)
      launch_pkg "$@"
      ;;
   is_installed)
      is_installed
      ;;
   is_enabled)
      is_enabled
      ;;
esac
