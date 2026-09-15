m = {}

pkg_id = "nerd-fonts-symbols"
installed_dir = fonts_dir .. "/" .. pkg_id

function m.install ()
   local github_repo = "ryanoasis/nerd-fonts"
   local filename_pattern = string.format("NerdFontsSymbolsOnly.tar.xz", xyz_mark)

   local remote_version, download_url, filename = fetch_github_release(
      pkg_id, github_repo, filename_pattern
   )
   if not remote_version then
      return false
   end
   local save_path = download_file(pkg_id, download_url, filename)
   if not save_path then
      return false
   end
   backup_old_installed(pkg_id, installed_dir)

   local cmdl, ok
   local ok = install_tarball(pkg_id, save_path, "tar", installed_dir)
   if not ok then
      return false
   end
   cmdl = "fc-cache -f"
   ok = os.execute(cmdl)
   if not ok then
      return false
   end
   write_version(pkg_id, remote_version)
end

function m.remove ()
   remove(pkg_id, installed_dir)
end

return m
