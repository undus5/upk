m = {}

channels = { beta = "beta", nightly = "nightly" }

function nil_or_channel (channel)
   if not channel or channel == "release" then
      return "release"
   end
   if channels[channel] then
      return channel
   end
   io.stderr:write("invalid channel\n")
   os.exit(1)
end

function get_pkg_id (channel)
   local channel = nil_or_channel(channel)
   local pkg_id_base = "brave-origin"
   if channel == "release" then
      return pkg_id_base
   end
   return pkg_id_base .. "-" .. channel
end

function fetch_remote_version (channel)
   assert_cmd("curl")
   local channel = nil_or_channel(channel)
   local pkg_id = get_pkg_id(channel)
   local api_url = "https://versions.brave.com/latest"
   api_url = api_url .. string.format("/origin-%s-linux-x64.version", channel)
   local f = io.popen("curl -s " .. api_url)
   local remote_version = f:read("l")
   f:close()
   return remote_version
end

function m.install (channel)
   local local_version, remote_version, outdated, filename, download_url
   local json_table, save_path, ok

   local pkg_id = get_pkg_id(channel)

   local_version = get_local_version(pkg_id)
   if local_version == "locked" then
      return false
   end

   io.write(string.format("[%s] fetching release info ... ", pkg_id))

   remote_version = fetch_remote_version(channel)
   outdated = is_local_version_outdated(pkg_id, remote_version)

   if outdated then
      io.write("outdated\n")
   else
      io.write("up to date\n")
      return false
   end

   filename_pattern = string.format("%s-%s-linux-amd64.zip", pkg_id, xyz_mark)

   api_url = "https://api.github.com/repos/brave/brave-browser"
   api_url = api_url .. "/releases/tags/v" .. remote_version

   local remote_version, download_url, filename = fetch_github_release(
      pkg_id, github_repo, filename_pattern, api_url, "quiet"
   )
   if not remote_version then
      return false
   end
   local save_path = download_file(pkg_id, download_url, filename)
   if not save_path then
      return false
   end
   backup_old_installed(pkg_id)

   ok = install_tarball(pkg_id, save_path, "unzip")
   if ok then
      write_version(pkg_id, remote_version)
      m.enable(channel)
   end
end

function m.enable (channel)
   local pkg_id = get_pkg_id(channel)
   local exec_path = string.format("%s/%s/%s", apps_dir, pkg_id, pkg_id)
   enable(pkg_id, exec_path)
end

function m.remove (channel)
   local pkg_id = get_pkg_id(channel)
   remove(pkg_id)
   m.disable(channel)
end

function m.disable (channel)
   local pkg_id = get_pkg_id(channel)
   disable(pkg_id)
end

return m
