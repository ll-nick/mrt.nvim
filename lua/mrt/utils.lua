local M = {}

M.execute_in_new_pane = function(command)
	vim.cmd("below split")
	vim.cmd("resize " .. settings.pane_height)
	vim.cmd("terminal " .. command)
end

	local settings = require("mrt.config").get_settings()
M.command_in_current_file_directory = function(command)
	local current_file_directory = vim.fn.expand("%:p:h")
	local execute_command = "pushd > /dev/null "
		.. current_file_directory
		.. " && "
		.. command
		.. " && popd > /dev/null"
	return execute_command
end

M.map_compile_commands = function()
	return "jq -s 'map(.[])' $(echo \"build_$(cat .catkin_tools/profiles/profiles.yaml | sed 's/active: //')\" | sed 's/_release//')/**/compile_commands.json > compile_commands.json"
end

M.pre_build_command = function()
	local settings = require("mrt.config").get_settings()
	return table.concat(settings.pre_build_commands, " && ")
end

M.is_catkin_workspace = function()
	local handle = io.popen("mrt catkin locate 2>&1")
	if not handle then
		print("Failed to open pipe for command execution.")
		return false
	end

	local result = handle:read("*a")
	handle:close()

	if result:match("No_catkin_workspace_root_found") or result:match("catkin: command not found") then
		return false
	end

	return true
end

return M
