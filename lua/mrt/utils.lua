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

M.find_workspace_root = function()
    local current_dir = vim.fn.getcwd()
    while current_dir ~= "/" do
        local catkin_tools_path = Path:new(current_dir, ".catkin_tools")
        if catkin_tools_path:exists() and catkin_tools_path:is_dir() then
            return current_dir
        end
        current_dir = Path:new(current_dir):parent().filename
    end
    return nil
end

M.is_catkin_workspace = function()
    return M.find_workspace_root() ~= nil
end

return M
