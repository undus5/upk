m = {}

pkg_id = "halloy"
exec_path = string.format("%s/%s/bin/halloy", apps_dir, pkg_id)

function m.install ()
   local github_repo = "squidowl/halloy"
   local filename_pattern = string.format("halloy-%s-x86_64-linux.tar.gz", xyz_mark)
   local ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
