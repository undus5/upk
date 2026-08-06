m = {}

pkg_id = "open-terminal"
cli_name = "open-terminal-here.sh"
cli_name_xdg = "xdg-terminal-exec"
exec_path = string.format("%s/%s/%s", apps_dir, pkg_id, cli_name) 

function m.install ()
   local lversion, ok
   lversion = local_version(pkg_id)
   if lversion == "locked" then
      return false
   end
   ok = install_cli_script(pkg_id, cli_name)
   if ok then
      lock(pkg_id)
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
   local cmdl, ok
   cmdl = string.format("cd %s;", bins_dir)
   cmdl = cmdl .. string.format(
      "ln -sf ../apps/%s/%s %s;", pkg_id, cli_name, cli_name_xdg
   )
   ok = os.execute(cmdl)
   if ok then
      tilde_symlink = tilde_path(bins_dir .. "/" .. cli_name_xdg)
      print(string.format("[%s] symlinked '%s'", pkg_id, tilde_symlink))
   end
end

function m.disable ()
   disable(pkg_id)
   local symlink, ok
   symlink = bins_dir .. "/" .. cli_name_xdg
   if file_exists(symlink) then
      os.execute("rm -f " .. symlink)
      print(string.format("[%s] removed '%s'", pkg_id, tilde_path(symlink)))
   end
end

return m
