# mrt.nvim

🎓 You work at the Institute of Measurement and Control Systems (MRT)? \
⬆️  You enjoy feeling superior to your colleagues? \
🗣️ You like to brag about your productive workflow while secretly wasting hours on configuring your setup? \
🔌 You hate how everything in VS Code just works? \
📄 You love READMEs consisting mostly of emojis and sarcasm?

Then why not switch your setup over to Neovim? 🤯

If you did and wonder how you can move your VS Code based workflow to Neovim, then this plugin is for you! 🎉

## 🚀 Features

- Execute builds with a single command
- Run build commands in a new neovim or tmux pane
- Switch your catkin profile interactively
 
## ⚡️ Requirements

- Neovim
- mrt tools
- jq (To map compile commands to a single file)
- tmux (optional)

## 📦 Installation

Use your favorite plugin manager to install this plugin.
For example, with [lazy.nvim](https://github.com/folke/lazy.nvim), the minimum configuration is:

```lua
{
  'll-nick/mrt.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
}
```

A more complete example:
```lua
{
    "ll-nick/mrt.nvim",
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function()
        require("mrt").setup({
            pane_handler = "tmux",
        })
    end,
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
- `:MrtSwitchCatkinProfile`: Switch the catkin profile interactively

### 🔧 Configuration

Here is an example configuration using the default values:

```lua
require("mrt").setup({
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
})
```

