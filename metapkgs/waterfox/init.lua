m = {}

pkg_id = "waterfox"
exec_path = string.format("%s/%s/waterfox", apps_dir, pkg_id)

function m.install ()
   local github_repo, filename, save_path, download_url, outdated
   local remote_version, ok

   github_repo = "BrowserWorks/waterfox"
   outdated, remote_version = fetch_github_release(pkg_id, github_repo)
   if not outdated then
      return false
   end

   filename = string.format("waterfox-%s.tar.bz2", remote_version)
   download_url = "https://cdn.waterfox.com/waterfox/releases/%s/Linux_x86_64/%s"
   download_url = string.format(download_url, remote_version, filename)

   save_path = download_file(pkg_id, filename, download_url)

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
