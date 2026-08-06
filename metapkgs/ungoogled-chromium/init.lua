m = {}

pkg_id = "ungoogled-chromium"
exec_path = string.format("%s/%s/%s.AppImage", apps_dir, pkg_id, pkg_id)

function fetch_remote_version (channel)
   assert_cmd("curl")
   local release_api, binary_api, f, json, remote_version
   local release_json_table, binary_json_table
   local release_versions, binary_versions, tmp_table

   release_api = "https://api.github.com/repos/ungoogled-software"
   release_api = release_api .."/ungoogled-chromium/releases"
   binary_api = "https://api.github.com/repos/ungoogled-software"
   binary_api = binary_api .. "/ungoogled-chromium-binaries"
   binary_api = binary_api .. "/contents/config/platforms/appimage/64bit"

   -- https://github.com/rxi/json.lua
   json = require("json")

   f = io.popen(github_curl_cmdl(release_api))
   release_json_table = json.decode(f:read("a"))
   f:close()

   release_versions = {}
   for i, v in ipairs(release_json_table) do
      if i > 3 then break end
      table.insert(release_versions, v.tag_name)
   end

   f = io.popen(github_curl_cmdl(binary_api))
   binary_json_table = json.decode(f:read("a"))
   f:close()

   tmp_table = {}
   for i, v in ipairs(binary_json_table) do
      local vv = v.name:gsub("%.ini", "")
      if vv:match("^%d%d%d%.") then
         table.insert(tmp_table, vv)
      end
   end
   binary_versions = {}
   for i = #tmp_table, #tmp_table - 3, -1 do
      table.insert(binary_versions, tmp_table[i])
   end

   for _, v in ipairs(release_versions) do
      if remote_version then
         break
      end
      for _, vv in ipairs(binary_versions) do
         if v == vv then
            remote_version = v
            break
         end
      end
   end

   return remote_version
end

function is_outdated (remote_version)
   local rsplit, lsplit, rvers, lvers = {}, {}, {}, {}
   local lversion = local_version(pkg_id)
   if not lversion then
      return true
   end
   if lversion == "locked" then
      return false
   end

   for s in remote_version:gmatch("[^%-]+") do
      table.insert(rsplit, s)
   end
   for s in rsplit[1]:gmatch("[^%.]+") do
      table.insert(rvers, s)
   end
   table.insert(rvers, rsplit[2])

   for s in lversion:gmatch("[^%-]+") do
      table.insert(lsplit, s)
   end
   for s in lsplit[1]:gmatch("[^%.]+") do
      table.insert(lvers, s)
   end
   table.insert(lvers, lsplit[2])

   for i, v in ipairs(rvers) do
      if rvers[i] > lvers[i] then
         return true
      end
   end
   return false
end

function m.install ()
   local lversion, remote_version, outdated, filename, download_url
   local save_path, ok

   lversion = local_version(pkg_id)
   if lversion == "locked" then
      return false
   end

   io.write(string.format("[%s] fetching release info ... ", pkg_id))

   remote_version = fetch_remote_version()

   outdated = is_outdated(remote_version)

   if outdated then
      io.write("outdated\n")
   else
      io.write("up to date\n")
      return false
   end

   filename = string.format("ungoogled-chromium-%s-x86_64.AppImage", remote_version)
   download_url = "https://github.com/ungoogled-software"
   download_url = download_url .. "/ungoogled-chromium-portablelinux"
   download_url = download_url .. "/releases/download/%s/%s"
   download_url = string.format(download_url, remote_version, filename)

   save_path = download_file(pkg_id, filename, download_url)

   if not save_path then
      return false
   end

   backup_old_installed(pkg_id)

   ok = install_binfile(pkg_id, save_path, exec_path)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable(pkg_id, exec_path)
end

return m
