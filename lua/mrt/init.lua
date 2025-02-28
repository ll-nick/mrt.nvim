local mrt = {}

local Path = require("plenary.path")

local build = require("mrt.build")
local catkin_profile = require("mrt.catkin_profile")
local config = require("mrt.config")
local package_picker = require("mrt.package_picker")
local utils = require("mrt.utils")
local overseer_setup = require("mrt.mrt_overseer_setup")

mrt.setup = config.setup

overseer_setup.register_templates()

mrt.build_workspace = function()
    local cwd = Path:new(vim.fn.getcwd())
    if not utils.is_in_catkin_workspace(cwd) then
        print("Command must be called from inside a catkin workspace.")
        return
    end

    overseer_setup.build_workspace()
end

mrt.build_current_package = function()
    local cwd = Path:new(vim.fn.getcwd())
    if not utils.is_in_catkin_workspace(cwd) then
        print("Command must be called from inside a catkin workspace.")
        return
    end

    overseer_setup.build_current_package()
end

mrt.build_current_package_tests = function()
    local cwd = Path:new(vim.fn.getcwd())
    if not utils.is_in_catkin_workspace(cwd) then
        print("Command must be called from inside a catkin workspace.")
        return
    end

    overseer_setup.build_current_package_tests()
end

mrt.switch_catkin_profile = function()
    local cwd = Path:new(vim.fn.getcwd())
    if not utils.is_in_catkin_workspace(cwd) then
        print("This is not a valid Catkin workspace.")
        return
    end

    catkin_profile.switch_profile_ui()
end

mrt.pick_catkin_package = function()
    local cwd = Path:new(vim.fn.getcwd())
    if not utils.is_in_catkin_workspace(cwd) then
        print("This is not a valid Catkin workspace.")
        return
    end

    package_picker.pick_catkin_package()
end

return mrt
