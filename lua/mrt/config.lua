local M = {}

local settings = {
	-- The flags for building an entire catkin workspace
	build_workspace_flags = "-j4 -c --no-coverage",

	-- The flags for building the current package
	build_package_flags = "-j4 -c --no-coverage",

	-- The flags for building tests for the current package
	build_package_tests_command = "-j4 -c --no-deps --no-coverage --verbose --catkin-make-args tests",
}

M.setup = function(options)
	settings = vim.tbl_extend("force", settings, options or {})
end

M.get_settings = function()
	return settings
end

return M
