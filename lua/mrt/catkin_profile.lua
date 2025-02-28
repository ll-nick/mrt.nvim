local M = {}

local get_profiles = function()
    local handle = io.popen("catkin profile list")
    if not handle then
        print("Failed to open pipe for command execution.")
        return false
    end

    local result = handle:read("*a")
    handle:close()

    local profiles = {}
    for profile in result:gmatch("- [^\r\n]+") do
        -- Remove the leading "- " from the profile name
        profile = profile:gsub("^%- ", "")
        table.insert(profiles, profile)
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
    vim.ui.select(get_profiles(), { prompt = "Select Catkin Profile:" }, function(selected_profile)
        if not selected_profile then
            return
        end

        local is_active = selected_profile:find("(active)") ~= nil
        if is_active then
            selected_profile = selected_profile:gsub(" %(active%)", "")
            print("Profile already selected: " .. selected_profile)
            return
        end

        set_profile(selected_profile)
        print("Switched to profile: " .. selected_profile)
    end)
end

return M
