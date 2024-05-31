local settings = require("mrt.config").get_settings()

local M = {}

M.execute_in_new_pane = function(command)
	vim.cmd("below split")
	vim.cmd("resize " .. settings.pane_height)
	vim.cmd("terminal " .. command)
end

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
	return table.concat(settings.pre_build_commands, " && ")
end

return M
