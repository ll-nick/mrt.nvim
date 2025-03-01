local M = {}

local settings = {
    --- The flags appended to the "mrt" command to build an entire catkin workspace
    --- @type string[]
    build_workspace_flags = { "build", "-j4", "-c", "--no-coverage" },

    --- The flags appended to the "mrt" command to build the current package
    --- @type string[]
    build_package_flags = { "build", "-j4", "-c", "--no-coverage", "--this" },

    --- The flags appended to the "mrt" command to build the tests for the current package
    --- @type string[]
    build_package_tests_flags = {
        "build",
        "-j4",
        "-c",
        "--this",
        "--no-deps",
        "--no-coverage",
        "--verbose",
        "--catkin-make-args",
        "tests",
    },
}

M.setup = function(options)
    settings = vim.tbl_extend("force", settings, options or {})
end

M.get_settings = function()
    return settings
end

return M
