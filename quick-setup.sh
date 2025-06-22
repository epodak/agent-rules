#!/bin/bash

# One-Click AI Rules Setup
# Download and run this script in any project directory

set -e

echo "🚀 One-Click AI Rules Setup"
echo "=========================="

# Download and execute the global installer
curl -s https://raw.githubusercontent.com/epodak/agent-rules/main/global-install.sh | bash

echo ""
echo "🎯 Setup complete! Your project now has intelligent AI rules." 