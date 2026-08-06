m = {}

pkg_id = "ibkr-desktop"
exec_path = string.format("%s/%s/ibkr-desktop.sh", apps_dir, pkg_id)

function m.install ()
   local lversion, filename, save_path, download_url
   local unpacked_dir, installed_dir, cmdl, ok
   lversion = local_version(pkg_id)
   if lversion and lversion == "locked" then
      return false
   end
   filename = "ntws-latest-standalone-linux-x64.sh"
   download_url = "https://download2.interactivebrokers.com/installers/ntws"
   download_url = download_url .. "/latest-standalone/" .. filename
   save_path = download_file(pkg_id, filename, download_url)
   backup_old_installed(pkg_id)

   unpack_dir = cache_dir .. "/" .. pkg_id
   installed_dir = apps_dir .. "/" .. pkg_id
   bwrap_script = string.format("%s/%s/bwrap.sh", metapkg_dir, pkg_id)
   cmdl = string.format("mkdir -p %s;", unpacked_dir)
   cmdl = cmdl .. string.format("chmod u+x %s;", save_path)
   cmdl = cmdl .. string.format("cp %s %s;", save_path, unpacked_dir)
   cmdl = cmdl .. string.format("%s %s ~/%s;", bwrap_script, unpacked_dir, filename)
   ok = os.execute(cmdl)
   if ok then
      cmdl = string.format("rm -f %s/%s;", unpacked_dir, filename)
      cmdl = cmdl .. string.format("mv %s %s;", unpacked_dir, installed_dir)
      ok = os.execute(cmdl)
   end
   if ok then
      ok = install_cli_script(pkg_id, "ibkr-desktop.sh")
   end
   if ok then
      ok = install_cli_script(pkg_id, "bwrap.sh")
   end
   if ok then
      print(string.format("[%s] installed '%s'", pkg_id, tilde_path(installed_dir)))
      lock(pkg_id)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
