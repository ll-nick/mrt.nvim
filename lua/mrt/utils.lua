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

M.get_plugin_path = function()
	local str = debug.getinfo(1, "S").source:sub(2)
	return str:match("(.*/)") .. "../../"
end

M.get_build_script_path = function()
	return M.get_plugin_path() .. "shell/build.sh" -- Just append shell/build.sh
end

M.has_dispatch = function()
	return vim.fn.exists(":Make") == 2
end

M.get_workspace_root = function()
	local workspace_root = get_workspace_info()

	if not is_catkin_workspace(workspace_root) then
		vim.notify("Command must be executed inside a catkin workspace.", vim.log.levels.ERROR)
		return nil
	end

	return workspace_root
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
