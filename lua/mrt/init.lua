local mrt = {}

local build = require("mrt.build")
local catkin_profile = require("mrt.catkin_profile")
local config = require("mrt.config")
local package_picker = require("mrt.package_picker")
local utils = require("mrt.utils")

mrt.setup = config.setup

mrt.build_workspace = function()
    if not utils.is_catkin_workspace() then
        print("Command must be called from inside a catkin workspace.")
        return
    end

    build.workspace()
end

mrt.build_current_package = function()
    if not utils.is_catkin_workspace() then
        print("Command must be called from inside a catkin workspace.")
        return
    end

    build.current_package()
end

mrt.build_current_package_tests = function()
    if not utils.is_catkin_workspace() then
        print("Command must be called from inside a catkin workspace.")
        return
    end

    build.current_package_tests()
end

mrt.switch_catkin_profile = function()
    if not utils.is_catkin_workspace() then
        print("This is not a valid Catkin workspace.")
        return
    end

    catkin_profile.switch_profile_ui()
end

mrt.pick_catkin_package = function()
    if not utils.is_catkin_workspace() then
        print("This is not a valid Catkin workspace.")
        return
    end

    package_picker.pick_catkin_package()
end

return mrt
