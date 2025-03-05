local Path = require("plenary.path")
local scan = require("plenary.scandir")

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
--- @param ws_root Path A directory inside the catkin workspace.
--- @return CatkinProfiles|nil A table containing the active profile and available profiles or nil if the command execution failed.
M.get_catkin_profiles = function(ws_root)
    if not ws_root then
        return nil
    end

    local profile_path = ws_root:joinpath(".catkin_tools/profiles")
    if not profile_path:exists() then
        return nil
    end

    local profiles_yaml = profile_path:joinpath("profiles.yaml")
    if not profiles_yaml:exists() then
        return nil
    end

    local active_profile = nil
    if profiles_yaml:exists() then
        for _, line in ipairs(profiles_yaml:readlines()) do
            local name = line:match("active: (.+)")
            if name then
                active_profile = name
                break
            end
        end
    end

    local available_profiles_absolute =
        scan.scan_dir(profile_path.filename, { depth = 1, add_dirs = true, only_dirs = true })
    local available_profiles = {}
    for _, profile in ipairs(available_profiles_absolute) do
        local profile_name = Path:new(profile):make_relative(profile_path.filename)
        if profile_name ~= active_profile then
            table.insert(available_profiles, profile_name)
        end
    end

    return {
        active = active_profile,
        available = available_profiles,
    }
end

return M
