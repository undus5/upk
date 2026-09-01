m = {}

pkg_id = "port-proton-qt"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "linux-gaming-ru/PortProtonQt"
   local filename_pattern = string.format("PortProtonQt-%s-anylinux-x86_64.AppImage", xyz_mark)
   local ok = install_binfile_release(pkg_id, github_repo, filename_pattern, exec_path)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
