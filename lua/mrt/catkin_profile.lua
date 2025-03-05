local Path = require("plenary.path")

local utils = require("mrt.utils")

--- Activate the given catkin profile.
--- @param profile string
local set_profile = function(profile)
    local handle = io.popen("mrt catkin profile set " .. profile)
    if not handle then
        vim.notify("Failed to open pipe for command execution.", vim.log.levels.ERROR)
        return
    end

    local result = handle:read("*a")
    handle:close()

    if not result or result == "" then
        vim.notify("Failed to switch profile. Command might not have executed properly.", vim.log.levels.ERROR)
    end
end

local M = {}
M.switch_profile_ui = function()
    local cwd = Path:new(vim.fn.getcwd())
    local ws_root = utils.find_workspace_root(cwd)
    local profiles = utils.get_catkin_profiles(ws_root)

    if not profiles then
        vim.notify("Failed to get catkin profiles.")
        return
    end

    if profiles.available == {} then
        vim.notify("No profiles available to switch to.")
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
        vim.notify("Switched to profile: " .. selected_profile)
    end)
end

return M
