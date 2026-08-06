#!/bin/lua

--------------------------------------------------------------------------------
-- helpers
--------------------------------------------------------------------------------

help_info = [=[
usage: upk.lua <sub_cmd> [app_id]
   list                              list available packages
   install|remove <app_id[s]> [-y]   -y skip confirmation
   update         [app_id[s]] [-y]   empty app_id means update all
   enable|disable <app_id[s]>        enable/disable desktop entry and icon
   lock           <app_id[s]>        prevent update and mark installed
   clean          [old]              clean cache
   -h|--help
]=]

function print_help ()
   io.write(help_info)
end

function dir_exists (path)
   -- appending a trailing slash works across both Unix and Windows systems
   local ok, err, code = os.rename(path .. "/", path .. "/")
   if not ok then
      if code == 13 then 
         -- code 13 means permission denied, but the directory DOES exist
         return true 
      end
      return false
   end
   return true
end

function file_exists (path)
   local f = io.open(path, "r")
   if f then
      f:close()
      return true
   else
      return false
   end
end

function exists_or_mkdir (path)
   if not dir_exists(path) then
      os.execute("mkdir -p " .. path)
   end
end

function assert_cmd (cmd)
   local ok
   if not cmd then
      return false
   end
   ok = os.execute(string.format("command -v %s &>/dev/null", cmd))
   if not ok then
      io.stderr:write(string.format("command not found: \n", cmd))
      os.exit(1)
   end
end

function tilde_path (path)
   local str = path:gsub(home_dir, "~")
   return str
end

--------------------------------------------------------------------------------
-- dirs
--------------------------------------------------------------------------------

home_dir = os.getenv("HOME")
upk_metapkg_dir = os.getenv("UPK_METAPKG_DIR")
upk_data_dir = os.getenv("UPK_DATA_DIR")

self_path = debug.getinfo(1, "S").source:sub(2)
f = io.popen("realpath " .. self_path)
self_path = f:read("l")
f:close()

proj_dir = self_path:match("(.*/)"):sub(1, -2)

if upk_metapkg_dir and dir_exists(upk_metapkg_dir) then
   metapkg_dir = upk_metapkg_dir
else
   metapkg_dir = proj_dir .. "/metapkgs"
end

entries_dir = home_dir .. "/.local/share/applications"
icons_dir = home_dir .. "/.icons"
fonts_dir = home_dir .. "/.local/share/fonts"

exists_or_mkdir(entries_dir)
exists_or_mkdir(icons_dir)
exists_or_mkdir(fonts_dir)

if upk_data_dir and dir_exists(upk_data_dir) then
   data_dir = upk_data_dir
else
   data_dir = home_dir .. "/upk.d"
end

apps_dir = data_dir .. "/apps"
bins_dir = data_dir .. "/bins"
vers_dir = data_dir .. "/vers"
runs_dir = data_dir .. "/runs"
cache_dir = data_dir .. "/cache"

exists_or_mkdir(apps_dir)
exists_or_mkdir(bins_dir)
exists_or_mkdir(vers_dir)
exists_or_mkdir(runs_dir)
exists_or_mkdir(cache_dir)

xyz_mark = ":XYZ:"

--------------------------------------------------------------------------------
-- modules
--------------------------------------------------------------------------------

package.path = proj_dir .. "/?.lua;" .. package.path

function load_metapkg (pkg_id)
   local path, mod_global_table, mod_env
   if package.loaded[pkg_id] then
      return package.loaded[pkg_id]
   end
   path = string.format("%s/%s/init.lua", metapkg_dir, pkg_id)
   if not file_exists(path) then
      io.stderr:write(string.format("metapkg not found: %s\n", pkg_id))
      os.exit(1)
   end
   mod_global_table = { _G = false }
   setmetatable(mod_global_table, { __index = _G })
   mod_env = {}
   setmetatable(mod_env, { __index = mod_global_table })
   package.loaded[pkg_id] = assert(loadfile(path, "t", mod_env))()
   return package.loaded[pkg_id]
end

--------------------------------------------------------------------------------
-- metapkg installation functions
--------------------------------------------------------------------------------

function download_github_release (pkg_id, filename_pattern, github_repo, api_url)
   local file_ext, json_table, download_url
   local remote_version, remote_xyz, lversion, local_xyz, outdated
   local filename, save_path, ok
   file_ext = ""
   file_ext = filename_pattern:match("%.zip") or file_ext
   file_ext = filename_pattern:match("%.tar%.%l+") or file_ext
   file_ext = filename_pattern:match("%.AppImage") or file_ext
   filename_pattern = filename_pattern:gsub(xyz_mark, "%%g+")
   filename_pattern = filename_pattern:gsub("([%-%.])", "%%%1")

   outdated, remote_version, json_table = fetch_github_release(pkg_id, github_repo, api_url)

   if not outdated then
      return false
   end

   for _, a in ipairs(json_table.assets) do
      if a.name:match(filename_pattern) then
         download_url = a.browser_download_url
         break
      end
   end

   filename = string.format("%s-%s%s", pkg_id, remote_version, file_ext)
   save_path = download_file(pkg_id, filename, download_url)

   return save_path, remote_version
end

function fetch_github_release (pkg_id, github_repo, api_url)
   local url, cmdl, f, json, json_table
   local remote_version, lversion, outdated

   url = "https://api.github.com/repos/%s/releases/latest"
   url = string.format(url, github_repo)
   url = api_url or url

   lversion = local_version(pkg_id)
   if lversion == "locked" then
      outdated = false
      return outdated, remote_version, json_table
   end

   io.write(string.format("[%s] fetching release info ... ", pkg_id))

   -- https://github.com/rxi/json.lua
   json = require("json")

   cmdl = github_curl_cmdl(url)
   f = io.popen(cmdl)
   json_table = json.decode(f:read("a"))
   f:close()

   remote_version = json_table.tag_name:match("[%d%.]+")

   outdated = is_outdated(pkg_id, remote_version)

   if outdated then
      io.write("outdated\n")
      return outdated, remote_version, json_table
   else
      io.write("up to date\n")
   end

   return outdated, remote_version, json_table
end

function is_outdated (pkg_id, remote_version)
   local outdated, lversion, remote_xyz, local_xyz
   outdated = false

   if not remote_version then
      io.stderr:write(string.format("[%s] invalid remote_version\n", pkg_id))
      os.exit(1)
   end

   lversion = local_version(pkg_id)
   if not lversion then
      outdated = true
      return outdated
   end

   remote_xyz = {}
   for v in remote_version:gmatch("[^%.]+") do
      table.insert(remote_xyz, tonumber(v))
   end
   local_xyz = {}
   for v in lversion:gmatch("[^%.]+") do
      table.insert(local_xyz, tonumber(v))
   end

   for i, v in ipairs(remote_xyz) do
      if remote_xyz[i] > local_xyz[i] then
         outdated = true
         break
      end
   end

   return outdated
end

function github_curl_cmdl (url)
   assert_cmd("curl")
   local github_token_file, f, token, cmdl
   github_token_file = home_dir .. "/.ssh/github-token.txt"
   f = io.open(github_token_file, "r")
   if f then
      token = f:read("l")
      f:close()
   end
   cmdl = "curl -s --header 'X-GitHub-Api-Version: 2026-03-10'"
   if token then
      cmdl = cmdl .. string.format(" --header 'Authorization: Bearer %s'", token)
   end
   return cmdl .. " --url " .. url
end

function download_file (pkg_id, filename, download_url)
   local save_path = cache_dir .. "/" .. filename
   io.write(string.format("[%s] downloading %s ... \n", pkg_id, filename))
   if file_exists(save_path) then
      io.write(string.format("[%s] found cache '%s'\n", pkg_id, tilde_path(save_path)))
   else
      cmdl = string.format("curl -#L -o %s --url %s", save_path, download_url)
      ok = os.execute(cmdl)
      if ok then
         io.write(string.format("[%s] saved '%s'\n", pkg_id, tilde_path(save_path)))
      else
         io.stderr:write(string.format("[%s] downloading failed\n", pkg_id))
         os.exit(1)
      end
   end
   return save_path
end

function backup_old_installed (pkg_id, installed_dir)
   local old_cached = string.format("%s/%s.old", cache_dir, pkg_id)
   installed_dir = installed_dir or string.format("%s/%s", apps_dir, pkg_id)
   os.execute("rm -rf " .. old_cached)
   if dir_exists(installed_dir) then
      os.execute(string.format("mv %s %s", installed_dir, old_cached))
   end
end

-- for AppImage and single binary release
function install_binfile_release (pkg_id, filename_pattern, github_repo, exec_path)
   local installed_dir = string.format("%s/%s", apps_dir, pkg_id)
   local save_path, remote_version = download_github_release(
      pkg_id, filename_pattern, github_repo
   )
   if not save_path then
      return false
   end
   backup_old_installed(pkg_id)
   local ok = install_binfile(pkg_id, save_path, exec_path)
   return ok
end

function install_binfile (pkg_id, save_path, exec_path)
   local installed_dir = string.format("%s/%s", apps_dir, pkg_id)
   local cmdl, ok
   cmdl = string.format("mkdir -p %s;", installed_dir)
   cmdl = cmdl .. string.format("chmod u+x %s;", save_path)
   cmdl = cmdl .. string.format("cp -f %s %s;", save_path, exec_path)
   ok = os.execute(cmdl)
   if ok then
      print(string.format("[%s] installed '%s'", pkg_id, tilde_path(installed_dir)))
   end
   return ok
end

function install_tarball_release (pkg_id, github_repo, filename_pattern)
   local save_path, remote_version = download_github_release(
      pkg_id, filename_pattern, github_repo
   )
   if not save_path then
      return false
   end
   backup_old_installed(pkg_id)
   local ok = install_tarball(pkg_id, save_path)
   return ok
end

function install_tarball (pkg_id, save_path, type)
   local unpacked_dir = cache_dir .. "/" .. pkg_id
   local installed_dir = string.format("%s/%s", apps_dir, pkg_id)
   local cmdl, ok, f, sub_dirs, sub_nodes_total, unpack_cmd
   unpack_cmd = string.format("tar xf %s -C %s;", save_path, unpacked_dir)
   if type == "unzip" then
      assert_cmd("unzip")
      unpack_cmd = string.format("unzip -q %s -d %s;", save_path, unpacked_dir)
   end
   cmdl = string.format("mkdir -p %s;", unpacked_dir) .. unpack_cmd
   ok = os.execute(cmdl)
   if not ok then
      io.stderr:write(string.format("[%s] unpacking failed\n", pkg_id))
      os.exit(1)
   end
   -- check unpacked has wrapping directory or not
   sub_dirs = {}
   cmdl = "find " .. unpacked_dir .. " -mindepth 1 -maxdepth 1 -type d"
   f = io.popen(cmdl)
   for d in f:lines() do
      table.insert(sub_dirs, d)
   end
   f:close()
   cmdl = "find " .. unpacked_dir .. " -mindepth 1 -maxdepth 1 | wc -l"
   f = io.popen(cmdl)
   sub_nodes_total = tonumber(f:read("l"))
   f:close()
   if #sub_dirs == 1 and sub_nodes_total == 1 then
      -- has wrapping directory
      cmdl = "mv %s %s; rm -rf %s;"
      cmdl = string.format(cmdl, sub_dirs[1], installed_dir, unpacked_dir)
   else
      -- no wrapping directory
      cmdl = string.format("mv %s %s;", unpacked_dir, installed_dir)
   end
   ok = os.execute(cmdl)
   if ok then
      print(string.format("[%s] installed '%s'", pkg_id, tilde_path(installed_dir)))
   end
   return ok
end

-- for caddy.sh, filebrowser.sh
function install_cli_script (pkg_id, cli_name)
   local installed_dir = string.format("%s/%s", apps_dir, pkg_id)
   local cli_path_src = metapkg_dir .. "/" .. pkg_id .. "/" .. cli_name
   local cli_path_dst = installed_dir .. "/" .. cli_name
   local cmdl, ok
   cmdl = string.format("mkdir -p %s;", installed_dir)
   cmdl = cmdl .. string.format("cp -f %s %s;", cli_path_src, cli_path_dst)
   ok = os.execute(cmdl)
   if ok then
      print(string.format("[%s] installed '%s'", pkg_id, tilde_path(cli_path_dst)))
   end
   return ok
end

function enable_cli (pkg_id, cli_name)
   if not cli_name then
      return false
   end
   local cli_path_rel = string.format("../apps/%s/%s", pkg_id, cli_name)
   local cli_path_link = bins_dir .. "/" .. cli_name
   local cmdl, ok
   cmdl = "cd %s; ln -sf %s %s"
   cmdl = string.format(cmdl, bins_dir, cli_path_rel, cli_path_link)
   ok = os.execute(cmdl)
   if ok then
      print(string.format("[%s] symlinked '%s'", pkg_id, tilde_path(cli_path_link)))
   end
end

function disable_cli (pkg_id, cli_name)
   if not cli_name then
      return false
   end
   local cli_path_link = bins_dir .. "/" .. cli_name
   local ok = os.execute("rm " .. cli_path_link)
   if ok then
      print(string.format("[%s] removed '%s'", pkg_id, tilde_path(cli_path_link)))
   end
end

function install (pkg_id)
   io.stderr:write(string.format("function not found: %s.install()\n", pkg_id))
   os.exit(1)
end

--------------------------------------------------------------------------------
-- metapkg other functions
--------------------------------------------------------------------------------

function remove (pkg_id, installed_dir)
   local installed_dir = installed_dir or string.format("%s/%s", apps_dir, pkg_id)
   local ok, version_file
   if dir_exists(installed_dir) then
      ok = os.execute("rm -rf " .. installed_dir)
      if ok then
         print(string.format("[%s] removed '%s'", pkg_id, tilde_path(installed_dir)))
      end
   end
   version_file = string.format("%s/%s.txt", vers_dir, pkg_id)
   if file_exists(version_file) then
      ok = os.execute("rm -f " .. version_file)
      if ok then
         print(string.format("[%s] removed '%s'", pkg_id, tilde_path(version_file)))
      end
   end
end

function enable (pkg_id, exec_path)
   assert_cmd("sed")

   local mod_dir = metapkg_dir .. "/" .. pkg_id
   local cmdl, f, file_path, dest_path, cmdll, ok, names

   cmdl = "find " .. mod_dir .. " -mindepth 1 -maxdepth 1 -type f"
   cmdl = cmdl .. " -name '*.png' -exec basename {} \\;"
   f = io.popen(cmdl)
   for file_name in f:lines() do
      file_path = mod_dir .. "/" .. file_name
      dest_path = icons_dir .. "/" .. file_name
      cmdll = string.format("cp -f %s %s", file_path, dest_path)
      ok = os.execute(cmdll)
      if ok then
         print(string.format("[%s] installed '%s'", pkg_id, tilde_path(dest_path)))
      end
   end
   f:close()

   cmdl = "find " .. mod_dir .. " -mindepth 1 -maxdepth 1 -type f"
   cmdl = cmdl .. " -name '*.desktop' -exec basename {} \\;"
   names = {}
   f = io.popen(cmdl)
   for file_name in f:lines() do
      table.insert(names, file_name)
   end
   f:close()
   if #names > 0 and not exec_path then
      io.stderr:write(string.format("exec_path not found for '%s'", pkg_id))
      os.exit(1)
   end
   for _, file_name in ipairs(names) do
      file_path = mod_dir .. "/" .. file_name
      dest_path = entries_dir .. "/" .. file_name
      cmdll = "sed s#Exec=#Exec=%s# %s > %s"
      cmdll = string.format(cmdll, exec_path, file_path, dest_path)
      ok = os.execute(cmdll)
      if ok then
         print(string.format("[%s] installed '%s'", pkg_id, tilde_path(dest_path)))
         os.execute("update-desktop-database " .. entries_dir)
      end
   end
end

function disable (pkg_id)
   local mod_dir = metapkg_dir .. "/" .. pkg_id
   local cmdl, f, dest_path, cmdll, ok

   cmdl = "find " .. mod_dir .. " -mindepth 1 -maxdepth 1 -type f"
   cmdl = cmdl .. " -name '*.png' -exec basename {} \\;"
   f = io.popen(cmdl)
   for file_name in f:lines() do
      dest_path = icons_dir .. "/" .. file_name
      if file_exists(dest_path) then
         cmdll = string.format("rm -f %s", dest_path)
         ok = os.execute(cmdll)
         if ok then
            print(string.format("[%s] removed '%s'", pkg_id, tilde_path(dest_path)))
            os.execute("update-desktop-database " .. entries_dir)
         end
      end
   end
   f:close()

   cmdl = "find " .. mod_dir .. " -mindepth 1 -maxdepth 1 -type f"
   cmdl = cmdl .. " -name '*.desktop' -exec basename {} \\;"
   f = io.popen(cmdl)
   for file_name in f:lines() do
      dest_path = entries_dir .. "/" .. file_name
      if file_exists(dest_path) then
         cmdll = "rm -f %s; update-desktop-database %s"
         cmdll = string.format(cmdll, dest_path, entries_dir)
         ok = os.execute(cmdll)
         if ok then
            print(string.format("[%s] removed '%s'", pkg_id, tilde_path(dest_path)))
         end
      end
   end
   f:close()
end

function lock (pkg_id)
   write_version(pkg_id, "locked")
end

function unlock (pkg_id)
   write_version(pkg_id, "")
end

function write_version (pkg_id, version)
   local path = string.format("%s/%s.txt", vers_dir, pkg_id)
   local ok = os.execute(string.format("printf '%s' > %s", version, path))
   if ok then
      print(string.format("[%s] wrote '%s' to '%s'", pkg_id, version, tilde_path(path)))
   end
end

function local_version (pkg_id)
   local path = string.format("%s/%s.txt", vers_dir, pkg_id)
   local f = io.open(path, "r")
   local lversion
   if f then
      lversion = f:read("l")
      f:close()
      if lversion and string.len(lversion) > 0 then
         return lversion
      else
         return false
      end
   end
   return false
end

--------------------------------------------------------------------------------
-- main
--------------------------------------------------------------------------------

function invoke_metapkgs (pkg_ids, sub_cmd)
   local mod
   if sub_cmd == "update" then
      sub_cmd = "install"
   end
   for _, pkg_id in ipairs(pkg_ids) do
      mod = load_metapkg(pkg_id)
      if mod[sub_cmd] then
         mod[sub_cmd]()
      else
         _G[sub_cmd](pkg_id)
      end
   end
end

function metapkg_list ()
   local cmdl, f, pkg_list
   cmdl = "find " .. metapkg_dir .. " -mindepth 1 -maxdepth 1 -type d"
   cmdl = cmdl .. " -exec basename {} \\;"
   f = io.popen(cmdl)
   pkg_list = {}
   for dir_name in f:lines() do
      table.insert(pkg_list, { pkg_id = dir_name, version = false })
   end
   f:close()
   for _, v in ipairs(pkg_list) do
      v.version = local_version(v.pkg_id)
   end
   return pkg_list
end

function list_info ()
   local pkg_list = metapkg_list()
   local strlen, maxlen = 0, 0
   local suffix
   for _, v in ipairs(pkg_list) do
      strlen = string.len(v.pkg_id)
      if maxlen < strlen then
         maxlen = strlen
      end
   end
   local column_fmt = "%-" .. maxlen .. "s"
   for _, v in ipairs(pkg_list) do
      io.write(string.format(column_fmt, v.pkg_id))
      suffix = "\n"
      if v.version then
         suffix = "   [installed]\n"
      end
      io.write(suffix)
   end
end

function clean_cache (tag)
   local cache_dir_tilde = tilde_path(cache_dir)
   local ok
   if tag == "old" then
      ok = os.execute(string.format("rm -rf %s/*.old", cache_dir))
      if ok then
         print(string.format("==> cleaned %s/*.old", cache_dir_tilde))
      end
   else
      ok = os.execute(string.format("rm -rf %s/*", cache_dir))
      if ok then
         print(string.format("==> cleaned %s/*", cache_dir_tilde))
      end
   end
end

cmds = {
   install = 1, update = 1, remove = 1,
   enable = 1, disable = 1, lock = 1, unlock = 1
}

cmds_no_confirmation = { enable = 1, disable = 1, lock = 1, unlock = 1 }

sub_cmd = arg[1]
if cmds[sub_cmd] then
   pkg_ids = {}
   pkg_ids_inline = ""
   skip_confirmation = false
   if cmds_no_confirmation[sub_cmd] then
      skip_confirmation = true
   end
   for i = 2, #arg do
      local str
      if arg[i] == "-y" then
         skip_confirmation = true
      else
         table.insert(pkg_ids, arg[i])
         str = ", " .. arg[i]
         if i == 2 then
            str = arg[i]
         end
         pkg_ids_inline = pkg_ids_inline .. str
      end
   end
   if #pkg_ids == 0 and sub_cmd == "update" then
      for i, v in ipairs(metapkg_list()) do
         local str
         if v.version then
            table.insert(pkg_ids, v.pkg_id)
            str = ", " .. v.pkg_id
            if i == 1 then
               str = v._pkg_id
            end
            pkg_ids_inline = pkg_ids_inline .. str
         end
      end
      if #pkg_ids == 0 then
         print("no package installed")
         os.exit(0)
      end
   end
   if #pkg_ids == 0 then
      io.stderr:write("missing pkg_ids\n")
      os.exit(1)
   end
   if not skip_confirmation then
      io.write("packages:\n   ", pkg_ids_inline, "\n")
      io.write(sub_cmd, " packages? [y/N]: ")
      ok, err = pcall(function ()
         answer = io.read()
      end)
      if not ok or not answer:match("[yY]") then
         os.exit(0)
      end
      if not ok then
         io.write("\n")
         if not err:match("interrupted!") then
            error(err)
         end
      end
   end
   invoke_metapkgs(pkg_ids, sub_cmd)
elseif sub_cmd == "launch" then
elseif sub_cmd == "list" then
   list_info()
elseif sub_cmd == "clean" then
   clean_cache(arg[2])
elseif sub_cmd == "-h" or sub_cmd == "--help" then
   print_help()
elseif sub_cmd == "test" then
else
   print_help()
   os.exit(1)
end

if #arg == 0 then
   print_help()
   os.exit(1)
end
