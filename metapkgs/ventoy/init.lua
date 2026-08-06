m = {}

pkg_id = "ventoy"
cli_name = "ventoy-cli.sh"
exec_path = string.format("%s/%s/ventoy-gui.sh", apps_dir, pkg_id)

function m.install ()
   local github_repo = "ventoy/Ventoy"
   local filename_pattern = string.format("ventoy-%s-linux.tar.gz", xyz_mark)
   local ok
   ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      ok = install_cli_script(pkg_id, cli_name)
   end
   if ok then
      ok = install_cli_script(pkg_id, "ventoy-gui.sh")
   end
   if ok then
      write_version(pkg_id, remote_version)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
   enable_cli(pkg_id, cli_name)
end

function m.disable ()
   disable(pkg_id)
   disable_cli(pkg_id, cli_name)
end

return m
