local overseer = require("overseer")
local Path = require("plenary.path")

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
                        logdir_cache = item.logdir
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
                    -- Prepend logdir
                    item.filename = logdir .. "/" .. item.filename

                    -- Resolve path
                    local resolved_path = Path:new(item.filename):normalize()
                    item.filename = resolved_path
                end
            end,
        },
    },
}

local register_build_workspace_template = function()
    overseer.register_template({
        name = "mrt_build_workspace",
        builder = function()
            return {
                cmd = "mrt",
                args = { "catkin", "build", "-j4", "-c", "--no-coverage" },
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
                },
            }
        end,
        condition = {
            callback = function()
                return vim.fn.executable("mrt") == 1 -- Ensure 'mrt' is available
            end,
        },
    })
end

local M = {}

M.register_templates = function()
    register_build_workspace_template()
end

M.run_build_workspace_template = function()
    overseer.run_template({ name = "mrt_build_workspace" })
end

return M
