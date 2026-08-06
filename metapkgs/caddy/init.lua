m = {}

pkg_id = "caddy"
cli_name = "caddy.sh"

function m.install ()
   local github_repo = "caddyserver/caddy"
   local filename_pattern = string.format("caddy_%s_linux_amd64.tar.gz", xyz_mark)
   local ok
   ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      ok = install_cli_script(pkg_id, cli_name)
   end
   if ok then
      write_version(pkg_id, remote_version)
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
