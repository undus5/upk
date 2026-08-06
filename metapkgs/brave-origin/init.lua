m = {}

pkg_id = "brave-origin"
exec_path = string.format("%s/%s/%s", apps_dir, pkg_id, pkg_id)

function fetch_remote_version (channel)
   assert_cmd("curl")
   channel = channel or "release"
   local api_url = "https://versions.brave.com/latest"
   api_url = api_url .. string.format("/origin-%s-linux-x64.version", channel)
   local f = io.popen("curl -s " .. api_url)
   local remote_version = f:read("l")
   f:close()
   return remote_version
end

function m.install (channel)
   channel = channel or "release"
   local lversion, remote_version, outdated, filename, download_url
   local json_table, save_path, ok

   lversion = local_version(pkg_id)
   if lversion == "locked" then
      return false
   end

   io.write(string.format("[%s] fetching release info ... ", pkg_id))

   remote_version = fetch_remote_version(channel)
   outdated = is_outdated(pkg_id, remote_version)

   if outdated then
      io.write("outdated\n")
   else
      io.write("up to date\n")
      return false
   end

   filename_pattern = string.format("%s-%s-linux-amd64.zip", pkg_id, xyz_mark)

   api_url = "https://api.github.com/repos/brave/brave-browser"
   api_url = api_url .. "/releases/tags/v" .. remote_version

   local save_path, remote_version = download_github_release(
      pkg_id, filename_pattern, github_repo, api_url
   )
   if not save_path then
      return false
   end

   backup_old_installed(pkg_id)

   ok = install_tarball(pkg_id, save_path, "unzip")
   if ok then
      write_version(pkg_id, remote_version)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
