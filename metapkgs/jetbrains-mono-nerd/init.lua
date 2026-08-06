m = {}

pkg_id = "jetbrains-mono-nerd"
installed_dir = fonts_dir .. "/" .. pkg_id

function m.install ()
   local github_repo = "ryanoasis/nerd-fonts"
   local filename_pattern = string.format("JetBrainsMono.tar.xz", xyz_mark)

   local save_path, remote_version = download_github_release(
      pkg_id, filename_pattern, github_repo
   )
   if not save_path then
      return false
   end
   backup_old_installed(pkg_id, installed_dir)

   local unpack_dir = cache_dir .. "/JetBrainsMonoNerd"
   local cmdl, ok
   cmdl = string.format("mkdir -p %s;", unpack_dir)
   cmdl = cmdl .. string.format("tar xf %s -C %s;", save_path, unpack_dir)
   cmdl = cmdl .. string.format("mkdir -p %s;", installed_dir)
   cmdl = cmdl .. string.format(
      "mv %s/JetBrainsMonoNL*.ttf %s;", unpack_dir, installed_dir
   )
   cmdl = cmdl .. string.format("rm -rf %s;", unpack_dir)
   cmdl = cmdl .. "fc-cache -f"
   ok = os.execute(cmdl)
   if ok then
      print(string.format("[%s] installed '%s'", pkg_id, tilde_path(installed_dir)))
      write_version(pkg_id, remote_version)
   end
end

return m
