#!/bin/bash

# Global Smart Rules Installer
# Can be called from any project directory to install AI rules

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
AGENT_RULES_REPO="git@github.com:epodak/agent-rules.git"
AGENT_RULES_DIR="$HOME/.agent-rules"
CURSOR_RULES_DIR=".cursor/rules"
CLAUDE_FILE="CLAUDE.md"

echo -e "${BLUE}🎯 Global Smart Rules Installer${NC}"
echo "====================================="

# Setup agent-rules repository
setup_agent_rules() {
    if [[ ! -d "$AGENT_RULES_DIR" ]]; then
        echo -e "${YELLOW}📦 Setting up agent-rules repository...${NC}"
        git clone "$AGENT_RULES_REPO" "$AGENT_RULES_DIR" 2>/dev/null || {
            echo -e "${RED}❌ Failed to clone repository. Creating local copy...${NC}"
            # Fallback: create minimal structure
            mkdir -p "$AGENT_RULES_DIR/project-rules"
            echo "Minimal setup completed."
            return 1
        }
        echo "  ✓ Repository cloned to $AGENT_RULES_DIR"
    else
        echo -e "${YELLOW}🔄 Updating agent-rules repository...${NC}"
        cd "$AGENT_RULES_DIR" && git pull origin main 2>/dev/null || {
            echo -e "${YELLOW}⚠ Update failed, using existing version${NC}"
        }
        cd - > /dev/null
        echo "  ✓ Repository updated"
    fi
}

# Detect project characteristics
detect_project_type() {
    local project_types=()
    
    echo -e "${YELLOW}🔍 Analyzing project structure...${NC}"
    
    # Check for JavaScript projects
    if [[ -f "package.json" ]]; then
        project_types+=("javascript")
        echo "  ✓ JavaScript/Node.js project detected (package.json)"
        
        # Check for frameworks
        if grep -q "react" package.json 2>/dev/null; then
            project_types+=("react")
            echo "  ✓ React framework detected"
        fi
        if grep -q "vue" package.json 2>/dev/null; then
            project_types+=("vue")
            echo "  ✓ Vue framework detected"
        fi
        if grep -q "next" package.json 2>/dev/null; then
            project_types+=("nextjs")
            echo "  ✓ Next.js framework detected"
        fi
    elif find . -maxdepth 2 -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -1 | grep -q "\.\(js\|ts\|jsx\|tsx\)$"; then
        project_types+=("javascript")
        echo "  ✓ JavaScript project detected (JS/TS files found)"
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        project_types+=("python")
        echo "  ✓ Python project detected"
        
        if [[ -f "manage.py" ]] || grep -q "django" requirements.txt 2>/dev/null; then
            project_types+=("django")
            echo "  ✓ Django framework detected"
        fi
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        project_types+=("rust")
        echo "  ✓ Rust project detected"
    fi
    
    if find . -maxdepth 2 -name "*.swift" -type f | head -1 | grep -q "swift"; then
        project_types+=("swift")
        echo "  ✓ Swift project detected"
    fi
    
    if [[ -f "go.mod" ]]; then
        project_types+=("go")
        echo "  ✓ Go project detected"
    fi
    
    # Check for development patterns
    if find . -maxdepth 3 -name "*.test.*" -o -name "*test*" -type f | head -1 | grep -q "test"; then
        project_types+=("testing")
        echo "  ✓ Testing setup detected"
    fi
    
    if [[ -d ".github" ]] || [[ -f ".gitlab-ci.yml" ]]; then
        project_types+=("ci_cd")
        echo "  ✓ CI/CD setup detected"
    fi
    
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        project_types+=("docker")
        echo "  ✓ Docker setup detected"
    fi
    
    echo "${project_types[@]}"
}

# Recommend rules based on project type
recommend_rules() {
    local project_types=("$@")
    local recommended_rules=()
    
    # Core rules for all projects (high-value universals)
    recommended_rules+=("implement-task" "bug-fix" "check" "commit" "clean" "quick-wins")
    
    # Add type-specific rules
    for type in "${project_types[@]}"; do
        case $type in
            "javascript"|"react"|"vue"|"nextjs")
                recommended_rules+=("code-analysis")
                ;;
            "python"|"django")
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
            "docker")
                recommended_rules+=("clean")
                ;;
        esac
    done
    
    # Add productivity rules
    recommended_rules+=("rule-effectiveness-tracker" "continuous-improvement")
    
    # Remove duplicates
    echo "${recommended_rules[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Install rules for Cursor
install_cursor_rules() {
    local rules=("$@")
    
    echo -e "${YELLOW}📁 Setting up Cursor rules...${NC}"
    mkdir -p "$CURSOR_RULES_DIR"
    
    local installed_count=0
    local missing_count=0
    
    for rule in "${rules[@]}"; do
        local rule_file="$AGENT_RULES_DIR/project-rules/${rule}.mdc"
        if [[ -f "$rule_file" ]]; then
            cp "$rule_file" "$CURSOR_RULES_DIR/"
            echo "  ✓ Installed: $rule.mdc"
            ((installed_count++))
        else
            echo -e "  ${RED}⚠ Missing: $rule.mdc${NC}"
            ((missing_count++))
        fi
    done
    
    echo -e "${GREEN}📊 Cursor installation summary:${NC}"
    echo "  ✅ Installed: $installed_count rules"
    if [[ $missing_count -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠ Missing: $missing_count rules${NC}"
    fi
}

# Install rules for Claude Code
install_claude_rules() {
    local rules=("$@")
    
    echo -e "${YELLOW}📝 Setting up Claude Code rules...${NC}"
    
    if [[ -f "$CLAUDE_FILE" ]]; then
        echo -e "${YELLOW}  📋 Backing up existing CLAUDE.md...${NC}"
        cp "$CLAUDE_FILE" "${CLAUDE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cat > "$CLAUDE_FILE" << 'EOF'
# Claude Code Rules

This file contains AI assistant rules for optimal development workflow.
Generated by Global Smart Rules Installer.

EOF
    
    local added_count=0
    local missing_count=0
    
    for rule in "${rules[@]}"; do
        local rule_file="$AGENT_RULES_DIR/project-rules/${rule}.mdc"
        if [[ -f "$rule_file" ]]; then
            echo "## $rule" >> "$CLAUDE_FILE"
            # Extract content without frontmatter
            sed '1,/^---$/d; /^---$/,$ d' "$rule_file" >> "$CLAUDE_FILE"
            echo "" >> "$CLAUDE_FILE"
            echo "  ✓ Added: $rule"
            ((added_count++))
        else
            echo -e "  ${RED}⚠ Missing: $rule${NC}"
            ((missing_count++))
        fi
    done
    
    echo -e "${GREEN}📊 Claude Code installation summary:${NC}"
    echo "  ✅ Added: $added_count rules"
    if [[ $missing_count -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠ Missing: $missing_count rules${NC}"
    fi
}

# Generate project-specific configuration
create_project_config() {
    local project_types=("$@")
    local project_name=$(basename "$(pwd)")
    
    cat > ".ai-rules-config.json" << EOF
{
  "project_name": "$project_name",
  "generated_date": "$(date -I)",
  "project_types": [$(printf '"%s",' "${project_types[@]}" | sed 's/,$//')]],
  "installed_rules": [$(printf '"%s",' "${recommended_rules[@]}" | sed 's/,$//')]],
  "effectiveness_tracking": {
    "enabled": true,
    "baseline_date": "$(date -I)",
    "next_review": "$(date -d '+7 days' -I)"
  },
  "auto_update": {
    "enabled": true,
    "check_frequency": "weekly",
    "last_check": "$(date -I)"
  },
  "agent_rules_version": "$(cd "$AGENT_RULES_DIR" && git rev-parse --short HEAD 2>/dev/null || echo 'local')"
}
EOF
    echo "  ✓ Created project configuration for $project_name"
}

# Create convenience alias
create_alias() {
    local alias_line="alias install-ai-rules='bash <(curl -s https://raw.githubusercontent.com/epodak/agent-rules/main/global-install.sh)'"
    
    echo -e "${YELLOW}💡 Pro tip: Add this alias to your shell profile:${NC}"
    echo -e "${BLUE}$alias_line${NC}"
    echo ""
    echo "Then you can run 'install-ai-rules' from any project directory!"
}

# Main installation flow
main() {
    local current_dir=$(pwd)
    echo -e "${BLUE}🏗️ Installing from: $current_dir${NC}"
    echo ""
    
    # Setup agent-rules repository
    setup_agent_rules
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
            echo ""
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
    echo -e "${GREEN}📈 Next steps:${NC}"
    echo "1. Start coding with AI rules active"
    echo "2. Run effectiveness analysis in 1 week:"
    echo -e "   ${BLUE}bash $AGENT_RULES_DIR/scripts/analyze-rule-effectiveness.sh${NC}"
    echo "3. Review and optimize monthly"
    echo ""
    
    # Show alias suggestion
    create_alias
    
    echo -e "${BLUE}Happy coding! ��${NC}"
}

main "$@" 