# mrt.nvim

🎓 You work at the Institute of Measurement and Control Systems (MRT)? \
⬆️  You enjoy feeling superior to your colleagues? \
🗣️ You like to brag about your productive workflow while secretly wasting hours on configuring your setup? \
🔌 You hate how everything in VS Code just works? \
📄 You love READMEs consisting mostly of emojis and sarcasm?

Then why not switch your setup over to Neovim? 🤯

If you did and wonder how you can move your VS Code based workflow to Neovim, then this plugin is for you! 🎉

## 🚀 Features

- Easily execute various build commands for your catkin workspace
- Parse build output and display diagnostics
- Switch packages using telescope
- Switch your catkin profile interactively
 
## ⚡️ Requirements

- mrt tools - duh
- jq - to merge compile commands to a single file
- [overseer.nvim](https://github.com/stevearc/overseer.nvim) - for task management and diagnostics
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - for some utility functions
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - for package switching

## 📦 Installation

Use your favorite plugin manager to install this plugin.
For example, with [lazy.nvim](https://github.com/folke/lazy.nvim), the minimum configuration is:

```lua
{
  "ll-nick/mrt.nvim",
  dependencies = { 
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    {
      "stevearc/overseer.nvim",
      opts = {},
    },
  }
```

A more complete example:
```lua
{
    "ll-nick/mrt.nvim",
    dependencies = { 
	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope.nvim",
	{
    	    "stevearc/overseer.nvim",
	    opts = {},
	    keys = {  
		{ "<leader>o", "<cmd>OverseerToggle<cr>", desc = "Toggle overseer" },
	    },
	},
    },
    opts = {
	overseer_components = {
	    "default",
	    "on_result_diagnostics",
	    -- To turn of auto open/close of quickfix list
	    { "on_result_diagnostics_quickfix", open = false, close = false },
	},
    },
    keys = {
        { "<leader>bw", "<cmd>MrtBuildWorkspace<cr>", desc = "Build workspace" },
        { "<leader>bp", "<cmd>MrtBuildCurrentPackage<cr>", desc = "Build current package" },
        { "<leader>bt", "<cmd>MrtBuildCurrentPackageTests<cr>", desc = "Build tests for current package" },
        { "<leader>sp", "<cmd>MrtSwitchCatkinProfile<cr>", desc = "Switch catkin profile" },
    },
}
```

## 📚 Usage

### Commands

- `:MrtBuildWorkspace`: Build the entire catkin workspace
- `:MrtBuildCurrentPackage`: Build the current package
- `:MrtBuildCurrentPackageTests`: Build tests for the current package
- `:MrtPickCatkinPackage`: Open the Readme of a catkin package using telescope
- `:MrtSwitchCatkinProfile`: Switch the catkin profile interactively

The build commands utilize the awesome [overseer.nvim](https://github.com/stevearc/overseer.nvim) plugin to manage tasks and display diagnostics.
You should probably have a look at their readme to see what you can do with it.
Most importantly, `:OverseerToggle` toggles the task list.

### 🔧 Configuration

Here's the default configuration:

```lua
require("mrt").setup({
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

    --- Additional overseer components to use for the build templates
    --- Note that the "on_output_parse" and "run_after" components are always included to
    --- parse the build output and merge the compile commands
    overseer_components = {
        "default",
        "on_result_diagnostics",
        { "on_result_diagnostics_quickfix", open = true, close = true },
    },
})
```

---

#### Disclaimer

This plugin is a side project of mine and not officially affiliated with the Institute of Measurement and Control Systems (MRT) in any way :)
