m = {}

pkg_id = "readest"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "readest/readest"
   local filename_pattern = string.format("Readest_%s_amd64.AppImage", xyz_mark)
   local ok = install_binfile_release(pkg_id, github_repo, filename_pattern, exec_path)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
