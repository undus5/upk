m = {}

pkg_id = "krita"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

function fetch_remote_version ()
   local url = "https://download.kde.org/stable/krita/"
   local pattern_v = "[0-9]+\\.[0-9]+\\.[0-9]+\\.*[0-9]*"
   local pattern_h = string.format('href="%s', pattern_v)
   local cmdl, f, version_dict, latest_version
   cmdl = "curl -s %s | grep -Eo '%s' | grep -Eo '%s' | uniq"
   cmdl = string.format(cmdl, url, pattern_h, pattern_v)
   versions = {}
   f = io.popen(cmdl)
   for l in f:lines() do
      table.insert(versions, l)
   end
   f:close()
   latest_version = "0.0.0.0"
   for _, v in ipairs(versions) do
      if compare_dot_version(v, latest_version) then
         latest_version = v
      end
   end
   return latest_version
end

function m.install ()
   local remote_version, filename, save_path, download_url, ok

   local local_version = get_local_version(pkg_id)
   if local_version and local_version == "locked" then
      return false
   end

   io.write(string.format("[%s] fetching release info ... ", pkg_id))

   remote_version = fetch_remote_version()

   outdated = is_local_version_outdated(pkg_id, remote_version)

   if outdated then
      io.write("outdated\n")
   else
      io.write("up to date\n")
      return false
   end

   filename = string.format("krita-%s-x86_64.AppImage", remote_version)
   download_url = "https://download.kde.org/stable/krita/%s/%s"
   download_url = string.format(download_url, remote_version, filename)

   save_path = download_file(pkg_id, download_url, filename)

   if not save_path then
      return false
   end

   backup_old_installed(pkg_id)

   ok = install_binfile(pkg_id, save_path, exec_path)
   if ok then
      write_version(pkg_id, remote_version)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
