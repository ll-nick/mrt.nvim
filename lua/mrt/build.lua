local config = require("mrt.config")
local utils = require("mrt.utils")

local function get_plugin_path()
	local str = debug.getinfo(1, "S").source:sub(2)
	return str:match("(.*/)")
end

local function get_build_script_path()
	return get_plugin_path() .. "../../shell/build.sh"
end

local function has_dispatch()
	return vim.fn.exists(":Make") == 2
end

local function get_workspace_root()
	-- Run 'catkin locate' to find the workspace root
	local workspace_root = vim.fn.system("mrt catkin locate")

	-- Trim any newline or trailing spaces from the output
	workspace_root = vim.fn.trim(workspace_root)

	-- Check if the command succeeded
	if workspace_root == "" then
		vim.notify("Failed to locate the workspace root.", vim.log.levels.ERROR)
		return nil
	end

	return workspace_root
end

local function get_package_name()
	-- Execute `catkin list --this --unformatted` in the directory of the current file
	local current_file_dir = vim.fn.expand("%:p:h")
	local package_name = vim.fn.system("cd " .. current_file_dir .. " && mrt catkin list --this --unformatted")

	-- Trim any newline or trailing spaces from the output
	package_name = vim.fn.trim(package_name)

	-- Check if the command succeeded and returned a valid package name
	if package_name == "" then
		vim.notify("No package found in the current directory.", vim.log.levels.ERROR)
		return nil
	end

	return package_name
end

local function run_build(flags)
	-- Determine the path to the shell script dynamically
	local script = get_build_script_path()
	local workspace_root = get_workspace_root()

	-- Set makeprg to the shell script, passing the directory and flags as arguments
	vim.opt_local.makeprg = script .. " " .. vim.fn.shellescape(workspace_root) .. " " .. vim.fn.shellescape(flags)

	if has_dispatch() then
		-- Use :Make (from tpope/dispatch) to run in the background
		vim.cmd("Make")
	else
		-- Use :make (built-in) to run synchronously
		vim.cmd("make")
	end
end

local M = {}

M.workspace = function()
	local flags = "-j4"
	run_build(flags)
end

M.current_package = function()
	local package_name = get_package_name()
	local flags = "-j4 " .. package_name
	run_build(flags)
end

M.current_package_tests = function()
	local package_name = get_package_name()
	local flags = "-j4 -c --no-deps --no-coverage --verbose --catkin-make-args tests" .. package_name
	run_build(flags)
end

return M
