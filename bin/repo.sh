#!/bin/bash
#
# repo.sh - Workspace Navigation & Link Management
#
# DESCRIPTION:
#   Resolves the physical location of the repository, creates a 
#   convenience shortcut in the user's home directory (~/repo),
#   and navigates the shell to the repository root.
#
# ----------------------------------------------------------------------

# 1. Resolve the physical path of this script
# Works even if called via a symlink in /usr/local/bin
REAL_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$REAL_PATH")
CURRENT_REPO_ROOT=$(dirname "$SCRIPT_DIR")

# 2. Define the Home Shortcut Path
HOME_SHORTCUT="$HOME/repo"

echo "Refreshing Lab Shortcuts..."

# 3. Create/Refresh the '~/repo' symlink
if [ -L "$HOME_SHORTCUT" ]; then
    rm "$HOME_SHORTCUT"
elif [ -d "$HOME_SHORTCUT" ]; then
    echo "⚠️  Warning: Physical directory ~/repo already exists. Skipping link."
fi

ln -sf "$CURRENT_REPO_ROOT" "$HOME_SHORTCUT"

# 4. Perform the "Jump"
# We use the resolved path to ensure we land in the right spot
if [ -d "$CURRENT_REPO_ROOT" ]; then
    cd "$CURRENT_REPO_ROOT"
    # Update the environment variable for the current session
    export REPO_ROOT="$CURRENT_REPO_ROOT"
fi

echo "✅ Success: ~/repo updated. Current directory: $PWD"
