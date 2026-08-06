m = {}

pkg_id = "zed"
exec_path = string.format("%s/%s/bin/zed", apps_dir, pkg_id)

function m.install ()
   local lversion = local_version(pkg_id)
   if lversion and lversion == "locked" then
      return false
   end
   local github_repo = "zed-industries/zed"
   local filename_pattern = string.format("zed-linux-x86_64.tar.gz", xyz_mark)
   local ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      lock(pkg_id)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
