local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local Path = require("plenary.path")
local scan = require("plenary.scandir")
local utils = require("mrt.utils")

local M = {}

local list_packages = function(workspace_path)
  local src_path = workspace_path .. "/src"
  local dirs = scan.scan_dir(src_path, { depth = 1, add_dirs = true, only_dirs = true })

  return dirs
end

local find_readme_or_fallback_file = function(package_path)
  local readme_path = Path:new(package_path):joinpath("README.md")
  if readme_path:exists() then
    return readme_path:absolute()
  end

  -- Fallback: Find any file in the package directory
  local files = scan.scan_dir(package_path, { depth = 1, add_dirs = false })
  if #files > 0 then
    return files[1]
  end

  return nil -- No files found
end

M.pick_catkin_package = function()
  local workspace_path = utils.find_workspace_root()
  local packages = list_packages(workspace_path)

  if vim.tbl_isempty(packages) then
    print("No packages found in " .. workspace_path .. "/src")
    return
  end

  pickers
    .new({}, {
      prompt_title = "Find Package",
      finder = finders.new_table({
        results = packages,
        entry_maker = function(entry)
          local package_name = Path:new(entry):make_relative(workspace_path .. "/src")
          return {
            value = entry,
            display = package_name,
            ordinal = package_name,
          }
        end,
      }),
      sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
      previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          local package_path = entry.value
          local preview_file = find_readme_or_fallback_file(package_path)
          if preview_file then
            return { "cat", preview_file }
          else
            return { "echo", "No files available in this package." }
          end
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            local package_path = selection.value
            local file_to_open = find_readme_or_fallback_file(package_path)
            if file_to_open then
              vim.cmd("edit " .. file_to_open)
            else
              vim.notify("No files found in " .. package_path, vim.log.levels.WARN)
            end
          end
        end)
        return true
      end,
    })
    :find()
end

return M
