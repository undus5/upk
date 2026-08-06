m = {}

pkg_id = "android-studio"
installed_dir = string.format("%s/%s", apps_dir, pkg_id)
exec_path = string.format("%s/bin/studio", installed_dir)

desc = [[
[android-studio] 'android-studio' do not support auto installation
[android-studio] 1. download from: https://developer.android.com/studio
[android-studio] 2. put into '%s'
[android-studio] 3. enable desktop entry
[android-studio] 4. lock package (to mark package as installed)
]]

desc = string.format(desc, tilde_path(exec_path))

function m.install ()
   io.write(desc)
end

function m.enable ()
   enable(pkg_id)
end

return m
