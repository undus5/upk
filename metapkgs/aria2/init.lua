m = {}

pkg_id = "aria2"
exec_path = string.format("%s/%s/%s.sh", apps_dir, pkg_id, pkg_id)

function m.install ()
   local local_version = get_local_version(pkg_id)
   if local_version and local_version == "locked" then
      return false
   end
   install_cli_script(pkg_id, exec_path)
   lock(pkg_id)
end

function m.enable ()
   enable_cli(pkg_id, exec_path)
end

return m
