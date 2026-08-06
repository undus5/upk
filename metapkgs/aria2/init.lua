m = {}

pkg_id = "aria2"
cli_name = "aria2.sh"

function m.install ()
   install_cli_script(pkg_id, cli_name)
   lock(pkg_id)
end

function m.enable ()
   enable_cli(pkg_id, cli_name)
end

return m
