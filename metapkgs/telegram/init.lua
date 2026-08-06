m = {}

pkg_id = "telegram"
exec_path = string.format("%s/%s/Telegram", apps_dir, pkg_id)

function m.install ()
   local lversion = local_version(pkg_id)
   if lversion and lversion == "locked" then
      return false
   end
   local filename, save_path, download_url, ok
   filename = "tsetup.tar.xz"
   download_url = "https://telegram.org/dl/desktop/linux"

   save_path = download_file(pkg_id, filename, download_url)

   backup_old_installed(pkg_id)
   ok = install_tarball(pkg_id, save_path)
   if ok then
      lock(pkg_id)
      m.enable()
   end
end

function m.enable ()
   print("[telegram] to enable desktop entry, need to manually start app once")
end

return m
