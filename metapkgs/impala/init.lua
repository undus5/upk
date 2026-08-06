m = {}

pkg_id = "impala"
cli_name = pkg_id
exec_path = string.format("%s/%s/%s", apps_dir, pkg_id, pkg_id)

function m.install ()
   local github_repo = "pythops/impala"
   local filename_pattern = string.format("impala-x86_64-unknown-linux-musl", xyz_mark)
   local ok = install_binfile_release(pkg_id, filename_pattern, github_repo, exec_path)
   if ok then
      m.enable()
   end
end

function m.enable ()
   enable_cli(pkg_id, cli_name)
end

return m
