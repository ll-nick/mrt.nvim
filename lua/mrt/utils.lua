local map_compile_commands = function()
	return "jq -s 'map(.[])' $(echo \"build_$(cat .catkin_tools/profiles/profiles.yaml | sed 's/active: //')\" | sed 's/_release//')/**/compile_commands.json > compile_commands.json"
end

local function run_command(cmd)
	local handle = io.popen(cmd .. " 2>&1") -- Redirect stderr to stdout
	if not handle then
		vim.notify("Failed to open pipe for command execution.", vim.log.levels.ERROR)
		return nil
	end

	local result = handle:read("*a") -- Read all output
	handle:close()

	return vim.fn.trim(result)
end

local function get_workspace_info()
	return run_command("mrt catkin locate")
end

local function is_catkin_workspace(workspace_info)
	if workspace_info:match("No_catkin_workspace_root_found") or workspace_info:match("catkin: command not found") then
		return false
	end

	return true
end

local M = {}

M.has_dispatch = function()
	return vim.fn.exists(":Make") == 2
end

M.is_catkin_workspace = function()
	local workspace_root = get_workspace_info()
	return is_catkin_workspace(workspace_root)
end

M.get_package_name = function()
	-- Execute `catkin list --this --unformatted` in the directory of the current file
	local current_file_dir = vim.fn.expand("%:p:h")
	local package_name = run_command("cd " .. current_file_dir .. " && mrt catkin list --this --unformatted")

	-- Check if the command succeeded and returned a valid package name
	if package_name == "" then
		vim.notify("No package found in the current directory.", vim.log.levels.ERROR)
		return nil
	end

	return package_name
end

M.map_compile_commands = function()
	return run_command(map_compile_commands())
end

return M
