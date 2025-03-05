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

--- Reads the active profile from profiles.yaml
--- @param profiles_yaml Path The path to profiles.yaml
--- @return string|nil The active profile name or nil if not found
local function get_active_profile(profiles_yaml)
    if not profiles_yaml:exists() then
        return nil
    end

    for _, line in ipairs(profiles_yaml:readlines()) do
        local name = line:match("active:%s*(.+)")
        if name then
            return name
        end
    end
    return nil
end

--- Retrieves all available catkin profiles
--- @param profile_path Path The path to the profiles directory
--- @return table A list of profile names
local function get_available_profiles(profile_path)
    if not profile_path:exists() then
        return {}
    end

    local available_profiles = {}
    local profiles_absolute = scan.scan_dir(profile_path.filename, { depth = 1, add_dirs = true, only_dirs = true })

    for _, profile in ipairs(profiles_absolute) do
        table.insert(available_profiles, Path:new(profile):make_relative(profile_path.filename))
    end

    return available_profiles
end

--- Retrieves the active and available catkin profiles
--- @param ws_root Path The root of the catkin workspace
--- @return table|nil A table containing the active profile and available profiles, or nil if invalid.
M.get_catkin_profiles = function(ws_root)
    if not ws_root then
        return nil
    end

    local profile_path = ws_root:joinpath(".catkin_tools/profiles")
    local profiles_yaml = profile_path:joinpath("profiles.yaml")

    local active_profile = get_active_profile(profiles_yaml)
    local available_profiles = get_available_profiles(profile_path)

    -- Remove the active profile from available profiles
    if active_profile then
        available_profiles = vim.tbl_filter(function(p)
            return p ~= active_profile
        end, available_profiles)
    end

    return {
        active = active_profile,
        available = available_profiles,
    }
end

return M
