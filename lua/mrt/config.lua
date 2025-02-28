local M = {}

local settings = {
    -- A list of commands to run before running a build command
    pre_build_commands = {
        "source /opt/mrtsoftware/setup.bash",
        "source /opt/mrtros/setup.bash",
    },

    -- The command to build an entire catkin workspace
    build_workspace_command = "mrt catkin build -j4 -c --no-coverage",

    -- The command to build the current package
    build_package_command = "mrt catkin build -j4 -c --no-coverage --this",

    -- The command to build tests for the current package
    build_package_tests_command = "mrt catkin build -j4 -c --this --no-deps --no-coverage --verbose --catkin-make-args tests",

    -- The terminal handler to use for running commands
    -- Valid values are "nvim" and "tmux"
    pane_handler = "nvim",

    -- The height of the terminal pane to open
    pane_height = 10,
}

M.setup = function(options)
    settings = vim.tbl_extend("force", settings, options or {})
end

M.get_settings = function()
    return settings
end

return M
