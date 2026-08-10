m = {}

mod = load_metapkg("brave-origin")
channel = "nightly"

function m.install ()
   mod.install(channel)
end

function m.enable ()
   mod.enable(channel)
end

function m.disable ()
   mod.disable(channel)
end

function m.remove ()
   mod.remove(channel)
end

return m
