m = {}

pkg_id = "aria2"
cli_name = "aria2.sh"

function m.install ()
   local local_version = get_local_version(pkg_id)
   if local_version and local_version == "locked" then
      return false
   end
   install_cli_script(pkg_id, cli_name)
   lock(pkg_id)
end

function m.enable ()
   enable_cli(pkg_id, cli_name)
end

return m
