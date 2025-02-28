local Path = require("plenary.path")

local M = {}

M.find_workspace_root = function(directory)
    local current_dir = directory
    while current_dir:absolute() ~= "/" do
        local catkin_tools_path = current_dir:joinpath(".catkin_tools")
        if catkin_tools_path:exists() and catkin_tools_path:is_dir() then
            return current_dir
        end
        current_dir = current_dir:parent()
    end
    return nil
end

M.is_in_catkin_workspace = function(directory)
    return M.find_workspace_root(directory) ~= nil
end

M.get_catkin_profiles = function()
    -- TODO: Replace this by manually parsing the .catkin_profile directory
    local handle = io.popen("mrt catkin profile list")
    if not handle then
        print("Failed to open pipe for command execution.")
        return false
    end

    local result = handle:read("*a")
    handle:close()

    local profiles = { active = nil, available = {} }
    for profile in result:gmatch("- [^\r\n]+") do
        -- Remove the leading "- " from the profile name
        local clean_profile = profile:gsub("^%- ", "")

        local is_active = clean_profile:find("%(active%)") ~= nil
        if is_active then
            -- Remove the "(active)" suffix from the profile name
            clean_profile = clean_profile:gsub(" %(active%)", "")
            profiles.active = clean_profile
        else
            table.insert(profiles.available, clean_profile)
        end
    end

    return profiles
end

return M
