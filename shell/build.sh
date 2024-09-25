#!/bin/bash
# build.sh

# Source the environment
source /opt/mrtsoftware/setup.bash
source /opt/mrtros/setup.bash

# Navigate to the directory passed as the first argument
cd "$1" || { echo "Failed to change directory to $1"; exit 1; }

# Print the current directory for confirmation
echo "Building in $(pwd)..."

# Disable colored output by setting TERM to dumb
export TERM=dumb
# Execute the build command with flags passed as the second argument
mrt build --no-color $2

# Run jq to merge compile_commands.json files
echo "Merging compile_commands.json files..."
jq -s 'map(.[])' $(echo "build_$(cat .catkin_tools/profiles/profiles.yaml | sed 's/active: //')" | sed 's/_release//')/**/compile_commands.json > compile_commands.json


# Notify the user
echo "Build completed."

