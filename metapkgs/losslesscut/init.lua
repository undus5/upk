m = {}

pkg_id = "losslesscut"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "mifi/lossless-cut"
   local filename_pattern = string.format("LosslessCut-linux-x86_64.AppImage", xyz_mark)
   local ok = install_binfile_release(pkg_id, filename_pattern, github_repo, exec_path)
   if ok then
      write_version(pkg_id, remote_version)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
