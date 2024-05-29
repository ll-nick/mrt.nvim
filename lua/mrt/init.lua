local mrt = {}

local config = {
	source_command = "source /opt/mrtsoftware/setup.bash && source /opt/mrtros/setup.bash",
	build_command = "mrt catkin build -j4 -c --no-coverage",
	pane_height = 10,
}

mrt.setup = function(options)
	config = vim.tbl_extend("force", config, options or {})
end

local execute_in_new_pane = function(command)
	vim.cmd("below split")
	vim.cmd("resize " .. config.pane_height)
	vim.cmd("terminal " .. command)
end

local command_in_current_file_directory = function(command)
	local current_file_directory = vim.fn.expand("%:p:h")
	local execute_command = "pushd > /dev/null "
		.. current_file_directory
		.. " && "
		.. command
		.. " && popd > /dev/null"
	return execute_command
end

local map_compile_commands = function()
	return "jq -s 'map(.[])' $(echo \"build_$(cat .catkin_tools/profiles/profiles.yaml | sed 's/active: //')\" | sed 's/_release//')/**/compile_commands.json > compile_commands.json"
end

mrt.build_workspace = function()
	local build_command = config.source_command .. " && " .. config.build_command .. " && " .. map_compile_commands()
	execute_in_new_pane(build_command)
end

mrt.build_current_package = function()
	local build_command = config.source_command
		.. " && "
		.. command_in_current_file_directory(config.build_command .. " --this")
		.. " && "
		.. map_compile_commands()
	execute_in_new_pane(build_command)
end

return mrt
