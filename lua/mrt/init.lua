local Path = require("plenary.path")

local catkin_profile = require("mrt.catkin_profile")
local config = require("mrt.config")
local mrt_overseer = require("mrt.overseer")
local package_picker = require("mrt.package_picker")
local utils = require("mrt.utils")

local run_command_if_in_workspace = function(command)
    local cwd = Path:new(vim.fn.getcwd())
    if not utils.is_in_catkin_workspace(cwd) then
        vim.notify("Command must be called from inside a catkin workspace.")
        return
    end

    command()
end

local mrt = {}

mrt.setup = config.setup

mrt_overseer.register_templates()

mrt.build_workspace = function()
    run_command_if_in_workspace(mrt_overseer.build_workspace)
end

mrt.build_current_package = function()
    run_command_if_in_workspace(mrt_overseer.build_current_package)
end

mrt.build_current_package_tests = function()
    run_command_if_in_workspace(mrt_overseer.build_current_package_tests)
end

mrt.switch_catkin_profile = function()
    run_command_if_in_workspace(catkin_profile.switch_profile_ui)
end

mrt.pick_catkin_package = function()
    run_command_if_in_workspace(package_picker.pick_catkin_package)
end

return mrt
