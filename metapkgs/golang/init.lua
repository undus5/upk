m = {}

pkg_id = "golang"
cli_name = "go"
exec_path = string.format("%s/%s/bin/go", apps_dir, pkg_id)

function fetch_release ()
   local remote_version, download_url, filename

   local local_version = get_local_version(pkg_id)
   if local_version == "locked" then
      return false
   end

   local url = "https://go.dev/dl/?mode=json"

   io.write(string.format("[%s] fetching release info ... ", pkg_id))

   -- https://github.com/rxi/json.lua
   local json = require("json")
   local json_table = {}

   local cmdl = "curl -s " .. url
   local f = io.popen(cmdl)
   json_table = json.decode(f:read("a"))
   f:close()

   if not json_table[1] or not json_table[1].version then
      return false
   end

   remote_version = json_table[1].version:sub(3)
   for _, f in ipairs(json_table[1].files) do
      local match = f.filename:match("^[%w%.]+linux%-amd64[%a%.]+$")
      if match then
         filename = match
         download_url = "https://go.dev/dl/" .. filename
         break
      end
   end

   local outdated = is_local_version_outdated(pkg_id, remote_version)

   if outdated and download_url then
      io.write("outdated\n")
      return remote_version, download_url, filename
   else
      io.write("up to date\n")
   end

   return false
end

function m.install ()
   local remote_version, download_url, filename = fetch_release()
   if not remote_version then
      return false
   end
   local save_path = download_file(pkg_id, download_url, filename)
   if not save_path then
      return false
   end
   backup_old_installed(pkg_id)
   local ok = install_tarball(pkg_id, save_path, exec_path)
   if ok then
      write_version(pkg_id, remote_version)
   end
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable_cli(pkg_id, exec_path)
end

function m.disable ()
   disable_cli(pkg_id, exec_path)
end

return m
