local config = require("mrt.config")
local utils = require("mrt.utils")

local function run_build(arguments)
	if not utils.is_catkin_workspace() then
		print("Command must be called from inside a catkin workspace.")
		return
	end

	if utils.has_dispatch() then
		-- Use :Make (from tpope/dispatch) to run in the background
		vim.cmd("Make " .. arguments)
	else
		-- Use :make (built-in) to run synchronously
		vim.cmd("make " .. arguments)
	end

	utils.map_compile_commands()
end

local M = {}

M.workspace = function()
	local settings = config.get_settings()
	run_build(settings.build_workspace_flags)
end

M.current_package = function()
	local settings = config.get_settings()
	local package_name = utils.get_package_name()
	local arguments = package_name .. " " .. settings.build_package_flags
	run_build(arguments)
end

M.current_package_tests = function()
	local settings = config.get_settings()
	local package_name = utils.get_package_name()
	local arguments = package_name .. " " .. settings.build_package_tests_command
	run_build(arguments)
end

return M
