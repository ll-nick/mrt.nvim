local config = require("mrt.config")
local utils = require("mrt.utils")

local map_compile_commands = function()
	return "jq -s 'map(.[])' $(echo \"build_$(cat .catkin_tools/profiles/profiles.yaml | sed 's/active: //')\" | sed 's/_release//')/**/compile_commands.json > compile_commands.json"
end

local pre_build_command = function()
	local settings = config.get_settings()
	return table.concat(settings.pre_build_commands, " && ")
end

local M = {}

M.workspace = function()
	local settings = config.get_settings()
	local build_command = pre_build_command() .. " && " .. settings.build_command .. " && " .. map_compile_commands()
	utils.execute_in_new_pane(build_command)
end

M.current_package = function()
	local settings = config.get_settings()
	local build_command = pre_build_command()
		.. " && "
		.. utils.command_in_current_file_directory(settings.build_command .. " --this")
		.. " && "
		.. map_compile_commands()
	utils.execute_in_new_pane(build_command)
end

return M
