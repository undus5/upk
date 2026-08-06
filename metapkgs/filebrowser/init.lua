m = {}

pkg_id = "filebrowser"
cli_name = "filebrowser.sh"

function m.install ()
   local github_repo = "filebrowser/filebrowser"
   local filename_pattern = string.format("linux-amd64-filebrowser.tar.gz", xyz_mark)
   local ok
   ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      ok = install_cli_script(pkg_id, cli_name)
   end
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable_cli(pkg_id, cli_name)
end

function m.disable ()
   disable_cli(pkg_id, cli_name)
end

return m
