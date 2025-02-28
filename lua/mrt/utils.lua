local Path = require("plenary.path")

local M = {}

local execute_in_new_nvim_pane = function(command, pane_height)
    vim.cmd("below split")
    vim.cmd("resize " .. pane_height)
    vim.cmd("terminal " .. command)
end

local execute_in_new_tmux_pane = function(command, pane_height)
    local split_window = "silent !tmux split-window -v -l " .. pane_height
    local execute_command_and_wait = string.format("bash -c \"%s; read -p 'Press Enter to exit'\"", command)
    local tmux_command = split_window .. " " .. execute_command_and_wait
    vim.cmd(tmux_command)
end

M.execute_in_new_pane = function(command)
    local settings = require("mrt.config").get_settings()
    if settings.pane_handler == "nvim" then
        execute_in_new_nvim_pane(command, settings.pane_height)
    elseif settings.pane_handler == "tmux" then
        execute_in_new_tmux_pane(command, settings.pane_height)
    else
        print("Invalid pane handler.")
    end
end

M.command_in_current_file_directory = function(command)
    local current_file_directory = vim.fn.expand("%:p:h")
    local execute_command = "pushd > /dev/null "
        .. current_file_directory
        .. " && "
        .. command
        .. " && popd > /dev/null"
    return execute_command
end

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
