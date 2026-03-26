#!/bin/bash
#
# check-env.sh - Environment Diagnostic Tool
#
# DESCRIPTION:
#   Verifies the health of the lab environment, checking for 
#   proper pathing, tethering, and library availability.
#
# ----------------------------------------------------------------------

source "$REPO_ROOT/lib/tools.sh"

echo "--- 🏥 Starfleet Environment Health Check ---"

# 1. Verify REPO_ROOT
if [ -z "$REPO_ROOT" ]; then
    echo "❌ ERROR: \$REPO_ROOT is not set. Your .bashrc is not tethered."
else
    echo "✅ SUCCESS: \$REPO_ROOT is set to $REPO_ROOT"
fi

# 2. Verify Pathing
if [[ ":$PATH:" == *":$REPO_ROOT/bin:"* ]]; then
    echo "✅ SUCCESS: bin/ directory is in your system PATH."
else
    echo "❌ ERROR: bin/ directory is missing from PATH."
fi

# 3. Verify Global Commands
if command -v repo.sh &> /dev/null; then
    echo "✅ SUCCESS: 'repo.sh' is accessible globally."
else
    echo "❌ ERROR: Global symlink for repo.sh is missing."
fi

# 4. Verify Library Permissions
if [ -r "$REPO_ROOT/lib/tools.sh" ] && [ ! -x "$REPO_ROOT/lib/tools.sh" ]; then
    echo "✅ SUCCESS: lib/tools.sh is readable but not executable (Secure)."
else
    echo "⚠️  WARNING: lib/ permissions are suboptimal."
fi

# 5. Verify External Dependencies
if command -v bc &> /dev/null; then
    echo "✅ SUCCESS: 'bc' calculator is installed."
else
    echo "❌ ERROR: 'bc' is missing. Run install-tools.sh."
fi

echo "--------------------------------------------"
echo "Diagnosis Complete."
