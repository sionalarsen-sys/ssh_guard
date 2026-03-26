#!/bin/bash
#
# setup-env.sh - Environment Tethering & Permission Sync
#
# DESCRIPTION:
#   Configures the user's shell environment by tethering the repository
#   to ~/.bashrc and ensuring all lab scripts are executable. This script
#   is designed to be idempotent and portable across different machines.
#
# USAGE:
#   ./.devcontainer/setup-env.sh
#
# ----------------------------------------------------------------------

# Capture the absolute path of the repository
REPO_DIR=$(pwd)

echo "--- 🛰️  Configuring Lab Workspace ---"

#######################################
# Injects the portable REPO_ROOT and PATH logic into ~/.bashrc.
#######################################
tether_bashrc() {
    local tether_block
    
    # We escape the first '$' in REPO_DIR so it's written as a literal variable.
    # This way, if the student moves the folder, the script stays dynamic.
    tether_block=$(cat <<EOF
# --- Lab Environment Setup (Added $(date +'%Y-%m-%d')) ---
# Use the current directory of the script if REPO_ROOT isn't set
export REPO_ROOT="$REPO_DIR"
if [ -d "\$REPO_ROOT" ]; then
    export PATH="\$PATH:\$REPO_ROOT/bin"
    # Source the repo-local .bashrc for custom prompts and aliases
    [ -f "\$REPO_ROOT/.bashrc" ] && . "\$REPO_ROOT/.bashrc"
fi
# -------------------------------------------------------
EOF
)

    # Ensure ~/.profile sources ~/.bashrc (Essential for Codespaces Login Shells)
    if [ -f ~/.profile ] && ! grep -q "source ~/.bashrc" ~/.profile; then
        echo -e "\nif [ -n \"\$BASH_VERSION\" ]; then\n    [ -f ~/.bashrc ] && . ~/.bashrc\nfi" >> ~/.profile
        echo "✅ Success: ~/.profile linked to ~/.bashrc"
    fi

    # Prevent duplicate entries in ~/.bashrc
    if ! grep -q "REPO_ROOT=\"$REPO_DIR\"" ~/.bashrc; then
        echo "$tether_block" >> ~/.bashrc
        echo "✅ Success: Repository tethered to ~/.bashrc"
    else
        echo "ℹ️  System: ~/.bashrc is already configured for this path."
    fi
}

#######################################
# Synchronizes permissions for the entire bin/ directory.
#######################################
sync_bin_permissions() {
    echo "🔧 Synchronizing script permissions..."
    
    if [ -d "$REPO_DIR/bin" ]; then
        # Ensure every script in bin is ready to run
        chmod ug+x "$REPO_DIR/bin/"*.sh
        echo "✅ Success: All scripts in bin/ are now executable."
    else
        echo "⚠️  Warning: bin/ directory not found."
    fi
}

# --- Execution ---

tether_bashrc
sync_bin_permissions

echo "--- ✅ Workspace Setup Complete ---"
