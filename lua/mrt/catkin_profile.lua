local M = {}

local get_profiles = function()
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

local set_profile = function(profile)
    local handle = io.popen("mrt catkin profile set " .. profile)
    if not handle then
        print("Failed to open pipe for command execution.")
        return false
    end
    handle:close()
end

M.switch_profile_ui = function()
    local profiles = get_profiles()

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
