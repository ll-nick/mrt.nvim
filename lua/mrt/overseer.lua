local overseer = require("overseer")
local Path = require("plenary.path")

local config = require("mrt.config")
local utils = require("mrt.utils")

local catkin_parser = {
    "sequence",
    -- This line will give us the log directory of the current package
    -- The gcc error messages will be relative to this directory and we need to adjust the paths
    { "extract", { append = false }, "^Errors%s+<<%s+[^:]+:make%s+(.+)/[^/]+$", "log_directory" },
    {
        -- Set the log_directory as a default value in all following items so we have access to it during the extraction postprocess.
        "set_defaults",
        {
            -- Now parse all messages from this package.
            "loop",
            {
                -- Try extracting an error message, then check the termination condition.
                "sequence",
                {
                    -- We want to keep going even if the extraction fails on a line.
                    "always",
                    {
                        -- Try extracting an error message. If successful, adjust the path to be relative to the cwd rather than the log directory.
                        "extract",
                        {
                            postprocess = function(item, result)
                                -- If the filename is already an absolute path, the error is from a system header and we don't want to adjust the path.
                                if item.filename:match("^/") then
                                    return
                                end
                                -- Prepend the log directory to the extracted path
                                local absolute_path =
                                    Path:new(result.default_values.log_directory):joinpath(item.filename):absolute()
                                item.filename = absolute_path
                            end,
                        },
                        -- This will match lines like
                        -- "../../src/package_name/file.cpp:123:45: error: message"
                        "([^:]+):(%d+):(%d+): (%w+): (.+)",
                        "filename",
                        "lnum",
                        "col",
                        "type",
                        "message",
                    },
                },
                -- Terminate the loop when we find the start of the next package.
                { "invert", { "test", "^Errors%s+<<" } },
            },
        },
    },
}

local register_compile_commands_template = function()
    overseer.register_template({
        name = "Merge Compile Commands",
        builder = function()
            return {
                cmd = {
                    "sh",
                },
                args = {
                    "-c",
                    "jq -s 'map(.[])' $(echo \"build_$(cat .catkin_tools/profiles/profiles.yaml | sed 's/active: //')\" | sed 's/_release//')/**/compile_commands.json > compile_commands.json",
                },
                cwd = utils.find_workspace_root(Path:new(vim.fn.getcwd())):absolute(),
                components = {
                    "on_exit_set_status",
                    {
                        "on_complete_dispose",
                        statuses = { "SUCCESS", "CANCELLED" },
                        timeout = 1,
                    },
                },
            }
        end,
        priority = 100,
        condition = {
            callback = function()
                return utils.is_in_catkin_workspace(Path:new(vim.fn.getcwd()))
            end,
        },
    })
end

local M = {}

--- Register a template with overseer that runs the `mrt` command with the given build arguments.
--- @param name string
--- @param build_arguments string[]
M.register_build_template = function(name, build_arguments)
    -- We will always use at least the following components
    local components = {
        { "on_output_parse", parser = { diagnostics = catkin_parser } },
        { "run_after", task_names = { "Merge Compile Commands" } },
    }

    -- Additional components can be added via the settings
    local settings = config.get_settings()
    local extra_components = settings.overseer_components
    if extra_components then
        vim.list_extend(components, extra_components)
    end

    overseer.register_template({
        name = name,
        builder = function()
            return {
                cmd = "mrt",
                args = build_arguments,
                components = components,
                cwd = vim.fn.expand("%:p:h"),
            }
        end,
        condition = {
            callback = function()
                return utils.is_in_catkin_workspace(Path:new(vim.fn.getcwd()))
            end,
        },
    })
end

M.register_templates = function()
    local settings = config.get_settings()

    register_compile_commands_template()

    M.register_build_template("MRT Build: Workspace", settings.build_workspace_flags)
    M.register_build_template("MRT Build: Current Package", settings.build_package_flags)
    M.register_build_template("MRT Build: Tests of Current Package", settings.build_package_tests_flags)
end

M.build_workspace = function()
    vim.notify("Building workspace...")
    overseer.run_template({ name = "MRT Build: Workspace" })
end

M.build_current_package = function()
    vim.notify("Building current package...")
    overseer.run_template({ name = "MRT Build: Current Package" })
end

M.build_current_package_tests = function()
    vim.notify("Building tests of current package...")
    overseer.run_template({ name = "MRT Build: Tests of Current Package" })
end

return M
