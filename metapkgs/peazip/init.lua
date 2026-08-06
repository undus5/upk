m = {}

pkg_id = "peazip"
exec_path = string.format("%s/%s/peazip", apps_dir, pkg_id)

function m.install ()
   local github_repo, filename_pattern
   github_repo = "peazip/PeaZip"
   filename_pattern = "peazip_portable-%s.LINUX.Qt6.x86_64.tar.gz"
   filename_pattern = string.format(filename_pattern, xyz_mark)
   local ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
