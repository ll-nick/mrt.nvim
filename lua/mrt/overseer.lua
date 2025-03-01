local overseer = require("overseer")
local Path = require("plenary.path")

local config = require("mrt.config")
local utils = require("mrt.utils")

local catkin_parser = {
    {
        -- Keep going even if the logdir extraction fails
        "always",
        {
            -- Extract logdir from the first line of the error message and cache it
            "extract",
            {
                append = false,
                postprocess = function(item, _)
                    if item.logdir then
                        logdir_cache = Path:new(item.logdir)
                        item.logdir = nil
                    end
                end,
            },
            "^Errors%s+<<%s+[^:]+:make%s+(.+)/[^/]+$",
            "logdir",
        },
    },
    {
        -- Extract diagnostics via the default gcc error format
        -- Adjust the path which is relative to the logdir
        "extract_efm",
        {
            postprocess = function(item, _)
                local cwd = vim.fn.getcwd()
                local logdir = logdir_cache
                if item.filename and logdir ~= "" then
                    -- Remove cwd from filename
                    item.filename = item.filename:gsub("^" .. vim.pesc(cwd) .. "/", "")
                    -- Prepend logdir and make it relative to the cwd
                    -- Vim will resolve the path to the cwd so is necessary in case the task runs in a different directory
                    item.filename = logdir:joinpath(item.filename):make_relative(cwd)
                end
            end,
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

local function register_build_template(name, build_arguments)
    overseer.register_template({
        name = name,
        builder = function()
            return {
                cmd = "mrt",
                args = build_arguments,
                components = {
                    "default",
                    {
                        "on_output_parse",
                        parser = {
                            diagnostics = catkin_parser,
                        },
                    },
                    "on_result_diagnostics",
                    "on_result_diagnostics_quickfix",
                    { "run_after", task_names = { "Merge Compile Commands" } },
                },
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

local M = {}

M.register_templates = function()
    local settings = config.get_settings()

    register_compile_commands_template()

    register_build_template("MRT Build: Workspace", settings.build_workspace_flags)
    register_build_template("MRT Build: Current Package", settings.build_package_flags)
    register_build_template("MRT Build: Tests of Current Package", settings.build_package_tests_flags)
end

M.build_workspace = function()
    overseer.run_template({ name = "MRT Build: Workspace" })
end

M.build_current_package = function()
    overseer.run_template({ name = "MRT Build: Current Package" })
end

M.build_current_package_tests = function()
    overseer.run_template({ name = "MRT Build: Tests of Current Package" })
end

return M
