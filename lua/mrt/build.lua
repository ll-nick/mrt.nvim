local config = require("mrt.config")
local utils = require("mrt.utils")

local function run_build(flags)
	-- Determine the path to the shell script dynamically
	local script = utils.get_build_script_path()
	local workspace_root = utils.get_workspace_root()

	-- Set makeprg to the shell script, passing the directory and flags as arguments
	vim.opt_local.makeprg = script .. " " .. vim.fn.shellescape(workspace_root) .. " " .. vim.fn.shellescape(flags)
	-- Set custom errorformat to parse the output of the build script
	vim.opt_local.errorformat = {
		-- Push build directory to directory stack to match relative paths of later error messages
		"%DErrors%\\s%\\+<< %\\w%\\+:%\\w%\\+ %f/build%.%#.log",
		-- Start error multiline error message
		"%E%f:%l:%c: %t%*[^:]: %m",
		-- Continue error multiline error message while there is a |
		"%C%.%#|%.%#",
		-- Default errorformat entries
		'%*[^"]"%f"%*\\D%l: %m',
		'"%f"%*\\D%l: %m',
		"%-Gg%\\?make[%*\\d]: *** [%f:%l:%m",
		"%-Gg%\\?make: *** [%f:%l:%m",
		"%-G%f:%l: (Each undeclared identifier is reported only once",
		"%-G%f:%l: for each function it appears in.)",
		"%-GIn file included from %f:%l:%c:",
		"%-GIn file included from %f:%l:%c\\,",
		"%-GIn file included from %f:%l:%c",
		"%-GIn file included from %f:%l",
		"%-G%*[ ]from %f:%l:%c",
		"%-G%*[ ]from %f:%l:",
		"%-G%*[ ]from %f:%l\\,",
		"%-G%*[ ]from %f:%l",
		"%f:%l:%c:%m",
		"%f(%l):%m",
		"%f:%l:%m",
		'"%f"\\, line %l%*\\D%c%*[^ ] %m',
		"%D%*\\a[%*\\d]: Entering directory %*[`']%f'",
		"%X%*\\a[%*\\d]: Leaving directory %*[`']%f'",
		"%D%*\\a: Entering directory %*[`']%f'",
		"%X%*\\a: Leaving directory %*[`']%f'",
		"%DMaking %*\\a in %f",
		"%f|%l| %m",
	}

	if utils.has_dispatch() then
		-- Use :Make (from tpope/dispatch) to run in the background
		vim.cmd("Make")
	else
		-- Use :make (built-in) to run synchronously
		vim.cmd("make")
	end
end

local M = {}

M.workspace = function()
	local settings = config.get_settings()
	run_build(settings.build_workspace_flags)
end

M.current_package = function()
	local settings = config.get_settings()
	local package_name = utils.get_package_name()
	local flags = settings.build_package_flags .. " " .. package_name
	run_build(flags)
end

M.current_package_tests = function()
	local settings = config.get_settings()
	local package_name = utils.get_package_name()
	local flags = settings.build_package_tests_command .. " " .. package_name
	run_build(flags)
end

return M
