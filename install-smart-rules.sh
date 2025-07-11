#!/bin/bash

# Smart Rules Installer
# Automatically detects project type and installs the most relevant rules

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CURSOR_RULES_DIR=".cursor/rules"
CLAUDE_FILE="CLAUDE.md"

echo -e "${BLUE}🎯 Smart Rules Installer${NC}"
echo "================================="

# Detect project characteristics
detect_project_type() {
    local project_types=()
    
    echo -e "${YELLOW}🔍 Analyzing project structure...${NC}"
    
    # Check for different project types
    if [[ -f "package.json" ]]; then
        project_types+=("javascript")
        echo "  ✓ JavaScript/Node.js project detected"
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        project_types+=("python")
        echo "  ✓ Python project detected"
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        project_types+=("rust")
        echo "  ✓ Rust project detected"
    fi
    
    if find . -name "*.swift" -type f | head -1 | grep -q "swift"; then
        project_types+=("swift")
        echo "  ✓ Swift project detected"
    fi
    
    if [[ -f "go.mod" ]]; then
        project_types+=("go")
        echo "  ✓ Go project detected"
    fi
    
    # Check for frameworks
    if [[ -f "package.json" ]] && grep -q "react" package.json; then
        project_types+=("react")
        echo "  ✓ React framework detected"
    fi
    
    if [[ -f "package.json" ]] && grep -q "vue" package.json; then
        project_types+=("vue")
        echo "  ✓ Vue framework detected"
    fi
    
    # Check for development patterns
    if find . -name "*.test.*" -o -name "*test*" -type f | head -1 | grep -q "test"; then
        project_types+=("testing")
        echo "  ✓ Testing setup detected"
    fi
    
    if [[ -d ".github" ]] || [[ -f ".gitlab-ci.yml" ]]; then
        project_types+=("ci_cd")
        echo "  ✓ CI/CD setup detected"
    fi
    
    echo "${project_types[@]}"
}

# Recommend rules based on project type
recommend_rules() {
    local project_types=("$@")
    local recommended_rules=()
    
    # Core rules for all projects
    recommended_rules+=("implement-task" "bug-fix" "check" "commit" "clean")
    
    # Add type-specific rules
    for type in "${project_types[@]}"; do
        case $type in
            "javascript"|"react"|"vue")
                recommended_rules+=("code-analysis")
                ;;
            "python")
                recommended_rules+=("code-analysis")
                ;;
            "swift")
                recommended_rules+=("modern-swift")
                ;;
            "testing")
                recommended_rules+=("five")
                ;;
            "ci_cd")
                recommended_rules+=("pr-review" "add-to-changelog")
                ;;
        esac
    done
    
    # Add productivity rules
    recommended_rules+=("quick-wins" "rule-effectiveness-tracker" "continuous-improvement")
    
    echo "${recommended_rules[@]}"
}

# Install rules for Cursor
install_cursor_rules() {
    local rules=("$@")
    
    echo -e "${YELLOW}📁 Setting up Cursor rules...${NC}"
    mkdir -p "$CURSOR_RULES_DIR"
    
    for rule in "${rules[@]}"; do
        local rule_file="project-rules/${rule}.mdc"
        if [[ -f "$rule_file" ]]; then
            cp "$rule_file" "$CURSOR_RULES_DIR/"
            echo "  ✓ Installed: $rule.mdc"
        else
            echo -e "  ${RED}⚠ Missing: $rule.mdc${NC}"
        fi
    done
}

# Install rules for Claude Code
install_claude_rules() {
    local rules=("$@")
    
    echo -e "${YELLOW}📝 Setting up Claude Code rules...${NC}"
    
    if [[ -f "$CLAUDE_FILE" ]]; then
        echo -e "${YELLOW}  Backing up existing CLAUDE.md...${NC}"
        cp "$CLAUDE_FILE" "${CLAUDE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cat > "$CLAUDE_FILE" << 'EOF'
# Claude Code Rules

This file contains AI assistant rules for optimal development workflow.
Generated by Smart Rules Installer.

EOF
    
    for rule in "${rules[@]}"; do
        local rule_file="project-rules/${rule}.mdc"
        if [[ -f "$rule_file" ]]; then
            echo "## $rule" >> "$CLAUDE_FILE"
            # Extract content without frontmatter
            sed '1,/^---$/d; /^---$/,$ d' "$rule_file" >> "$CLAUDE_FILE"
            echo "" >> "$CLAUDE_FILE"
            echo "  ✓ Added: $rule"
        fi
    done
}

# Generate project-specific configuration
create_project_config() {
    local project_types=("$@")
    
    cat > ".ai-rules-config.json" << EOF
{
  "generated_date": "$(date -I)",
  "project_types": [$(printf '"%s",' "${project_types[@]}" | sed 's/,$//')]],
  "installed_rules": [$(printf '"%s",' "${recommended_rules[@]}" | sed 's/,$//')]],
  "effectiveness_tracking": {
    "enabled": true,
    "next_review": "$(date -d '+7 days' -I)"
  },
  "auto_update": {
    "enabled": true,
    "check_frequency": "weekly"
  }
}
EOF
    echo "  ✓ Created project configuration"
}

# Main installation flow
main() {
    echo -e "${BLUE}Starting smart installation...${NC}"
    echo ""
    
    # Detect project
    local project_types=($(detect_project_type))
    echo ""
    
    if [[ ${#project_types[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No specific project type detected. Installing universal rules.${NC}"
        project_types=("universal")
    fi
    
    # Get recommendations
    local recommended_rules=($(recommend_rules "${project_types[@]}"))
    
    echo -e "${GREEN}📋 Recommended rules for your project:${NC}"
    for rule in "${recommended_rules[@]}"; do
        echo "  • $rule"
    done
    echo ""
    
    # Ask for installation preference
    echo -e "${YELLOW}Choose installation target:${NC}"
    echo "1) Cursor (.cursor/rules/)"
    echo "2) Claude Code (CLAUDE.md)"  
    echo "3) Both"
    echo "4) Exit"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            install_cursor_rules "${recommended_rules[@]}"
            ;;
        2)
            install_claude_rules "${recommended_rules[@]}"
            ;;
        3)
            install_cursor_rules "${recommended_rules[@]}"
            install_claude_rules "${recommended_rules[@]}"
            ;;
        4)
            echo "Installation cancelled."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
    
    # Create configuration
    echo ""
    echo -e "${YELLOW}📊 Creating project configuration...${NC}"
    create_project_config "${project_types[@]}"
    
    # Final steps
    echo ""
    echo -e "${GREEN}🎉 Installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run './scripts/analyze-rule-effectiveness.sh' in 1 week"
    echo "2. Review rule effectiveness monthly"  
    echo "3. Update rules based on project evolution"
    echo ""
    echo -e "${BLUE}Happy coding! 🚀${NC}"
}

# Check if we're in the agent-rules directory
if [[ ! -f "project-rules/implement-task.mdc" ]]; then
    echo -e "${RED}Error: Please run this script from the agent-rules directory${NC}"
    exit 1
fi

main "$@" 