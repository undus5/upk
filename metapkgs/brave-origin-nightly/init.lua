m = {}

pkg_id = "brave-origin-nightly"
exec_path = string.format("%s/%s/%s", apps_dir, pkg_id, pkg_id)

function m.install ()
   local mod = load_metapkg("brave-origin")
   mod.install("nightly")
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
