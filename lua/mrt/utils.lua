local M = {}

--- Finds the root directory of a catkin workspace by searching for the `.catkin_tools` directory in the parent directories.
--- @param directory Path The starting directory for the search.
--- @return Path|nil workspace_root The root directory of the catkin workspace if the given directory is inside a catkin workspace, otherwise nil.
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

--- Checks if a given directory is inside a catkin workspace.
--- @param directory Path The directory to check.
--- @return boolean is_inside `true` if inside a catkin workspace, otherwise `false`.
M.is_in_catkin_workspace = function(directory)
    return M.find_workspace_root(directory) ~= nil
end

--- @class CatkinProfiles
--- @field active string|nil The currently active catkin profile.
--- @field available string[] A list of available profiles excluding the active one.

--- Retrieves the active and available catkin profiles
--- @return CatkinProfiles|nil A table containing the active profile and available profiles or nil if the command execution failed.
M.get_catkin_profiles = function()
    -- TODO: Replace this by manually parsing the .catkin_profile directory
    local handle = io.popen("mrt catkin profile list")
    if not handle then
        print("Failed to open pipe for command execution.")
        return nil
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
