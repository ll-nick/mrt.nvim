local M = {}

local settings = {
	pre_build_commands = {
		"source /opt/mrtsoftware/setup.bash",
		"source /opt/mrtros/setup.bash",
	},
	build_command = "mrt catkin build -j4 -c --no-coverage",
	pane_height = 10,
}

M.setup = function(options)
	settings = vim.tbl_extend("force", settings, options or {})
end

M.get_settings = function()
	return settings
end

return M
