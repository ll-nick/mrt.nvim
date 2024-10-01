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
- Execute synchronous or asynchronous builds
- Utilize the quickfix list to navigate through build errors
- Switch your catkin profile interactively
 
## ⚡️ Requirements

- Neovim
- mrt tools
- jq (To map compile commands to a single file)
- [tpope/vim-dispatch](https://github.com/tpope/vim-dispatch) (Optional, for asynchronous builds)

## 📦 Installation

Use your favorite plugin manager to install this plugin.
For example, with [lazy.nvim](https://github.com/folke/lazy.nvim), the minimum configuration is:

```lua
{
  'll-nick/mrt.nvim',
}
```

A more complete example:
```lua
{
    "ll-nick/mrt.nvim",

  	dependencies = {
		{ "tpope/vim-dispatch" }, -- for asynchronous builds
	},

    config = function()
        require("mrt").setup({
            build_workspace_flags = "-j128",
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
	-- The flags for building an entire catkin workspace
	build_workspace_flags = "-j4 -c --no-coverage",

	-- The flags for building the current package
	build_package_flags = "-j4 -c --no-coverage",

	-- The flags for building tests for the current package
	build_package_tests_command = "-j4 -c --no-deps --no-coverage --verbose --catkin-make-args tests",
})
```

