m = {}

pkg_id = "openrgb"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

desc = [[
[openrgb] 'openrgb' releases do not follow consistent pattern, need to install manually:
[openrgb] 1. download AppImage from: https://github.com/CalcProgrammer1/OpenRGB/releases/
[openrgb] 2. put into '%s'
[openrgb] 3. enable desktop entry
[openrgb] 4. lock package (to mark package as installed)
[openrgb] 5. download '60-openrgb.rules', put into '/etc/udev/rules.d/'
[openrgb] 6. run 'udevadm control --reload-rules' and 'udevadm trigger'
]]

desc = string.format(desc, tilde_path(exec_path))

function m.install ()
   io.write(desc)
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
