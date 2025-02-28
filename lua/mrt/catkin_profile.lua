local utils = require("mrt.utils")

local set_profile = function(profile)
    local handle = io.popen("mrt catkin profile set " .. profile)
    if not handle then
        print("Failed to open pipe for command execution.")
        return false
    end
    handle:close()
end

local M = {}
M.switch_profile_ui = function()
    local profiles = utils.get_catkin_profiles()

    if not profiles then
        print("Failed to get Catkin profiles.")
        return
    end

    if profiles.available == {} then
        print("No profiles available to switch to.")
        return
    end

    local prompt = "Select Catkin Profile:"
    if profiles.active then
        prompt = prompt .. " (Current: " .. profiles.active .. ")"
    end

    vim.ui.select(profiles.available, { prompt = prompt }, function(selected_profile)
        if not selected_profile then
            return
        end

        set_profile(selected_profile)
        print("Switched to profile: " .. selected_profile)
    end)
end

return M
