m = {}

pkg_id = "caddy"
exec_path = string.format("%s/%s/%s.sh", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "caddyserver/caddy"
   local filename_pattern = string.format("caddy_%s_linux_amd64.tar.gz", xyz_mark)
   local ok
   ok = install_tarball_release(pkg_id, github_repo, filename_pattern)
   if ok then
      ok = install_cli_script(pkg_id, exec_path)
   end
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
