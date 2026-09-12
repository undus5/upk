m = {}

pkg_id = "lazygit"
exec_path = string.format("%s/%s/%s", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "jesseduffield/lazygit"
   local filename_pattern = string.format("lazygit_%s_linux_x86_64.tar.gz", xyz_mark)
   local ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable_cli(pkg_id, exec_path)
end

function m.disable ()
   disable_cli(pkg_id, exec_path)
end

return m
