m = {}

pkg_id = "helium"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "imputnet/helium-linux"
   local filename_pattern = string.format("helium-%s-x86_64.AppImage", xyz_mark)
   local ok = install_binfile_release(pkg_id, filename_pattern, github_repo, exec_path)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
