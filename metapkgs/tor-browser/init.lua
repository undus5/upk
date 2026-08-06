m = {}

pkg_id = "tor-browser"
exec_path = string.format("%s/%s/Browser/start-tor-browser", apps_dir, pkg_id)

function fetch_remote_version ()
   local url = "https://dist.torproject.org/torbrowser/"
   local pattern_v = "[0-9]+\\.[0-9]+\\.[0-9]+"
   local pattern_h = string.format('href="%s', pattern_v)
   local cmdl, f, remote_version
   cmdl = "curl -s %s | grep -Eo '%s' | grep -Eo '%s'"
   cmdl = string.format(cmdl, url, pattern_h, pattern_v)
   f = io.popen(cmdl)
   remote_version = f:read("l")
   f:close()
   return remote_version
end

function m.install ()
   local remote_version, filename, save_path, download_url, ok

   local lversion = local_version(pkg_id)
   if lversion and lversion == "locked" then
      return false
   end

   remote_version = fetch_remote_version()

   filename = string.format("tor-browser-linux-x86_64-%s.tar.xz", remote_version)
   download_url = "https://www.torproject.org/dist/torbrowser/%s/%s"
   download_url = string.format(download_url, remote_version, filename)

   save_path = download_file(pkg_id, filename, download_url)

   if not save_path then
      return false
   end

   backup_old_installed(pkg_id)

   ok = install_tarball(pkg_id, save_path)
   if ok then
      lock(pkg_id)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
