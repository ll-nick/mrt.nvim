local mrt = {}

local config = require("mrt.config")
local utils = require("mrt.utils")

mrt.setup = require("mrt.config").setup
local settings = config.get_settings()

mrt.build_workspace = function()
	local build_command = utils.pre_build_command()
		.. " && "
		.. settings.build_command
		.. " && "
		.. utils.map_compile_commands()
	utils.execute_in_new_pane(build_command)
end

mrt.build_current_package = function()
	local build_command = utils.pre_build_command()
		.. " && "
		.. utils.command_in_current_file_directory(settings.build_command .. " --this")
		.. " && "
		.. utils.map_compile_commands()
	utils.execute_in_new_pane(build_command)
end

return mrt
