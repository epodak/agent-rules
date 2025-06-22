#!/bin/bash

# Global Rules (grule) - AI Rules Management Tool
# Deploy and manage AI assistant rules across projects

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

function grule() {
    # 显示帮助信息
    function show_help() {
        echo "使用方法: grule [options]"
        echo ""
        echo "AI规则管理工具 - 部署和管理AI助手规则"
        echo ""
        echo "参数说明:"
        echo "  -d, --deploy      部署规则到本地系统"
        echo "  -i, --install     在当前项目中安装规则"
        echo "  -u, --update      更新本地规则库"
        echo "  -s, --status      显示规则状态"
        echo "  -p, --path PATH   指定自定义规则路径"
        echo "  -t, --target TYPE 指定安装目标 (cursor|claude|both)"
        echo "  -f, --force       强制覆盖现有规则"
        echo "  -h, --help        显示帮助信息"
        echo "  -l, --log         启用详细日志"
        echo ""
        echo "示例:"
        echo "  grule --deploy                    # 首次部署到本地"
        echo "  grule --install                   # 在项目中安装规则"
        echo "  grule --install --target cursor   # 只安装到Cursor"
        echo "  grule --update --log              # 更新规则并显示日志"
        echo "  grule --status                    # 查看规则状态"
    }

    # 日志记录函数
    function log_message() {
        if $log_enabled; then
            echo -e "${BLUE}[LOG]${NC} $1"
        fi
    }

    # 错误信息函数
    function error_message() {
        echo -e "${RED}[ERROR]${NC} $1" >&2
    }

    # 成功信息函数
    function success_message() {
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    }

    # 警告信息函数
    function warning_message() {
        echo -e "${YELLOW}[WARNING]${NC} $1"
    }

    # 检查规则库状态
    function check_rules_status() {
        local agent_rules_dir="$HOME/.agent-rules"
        
        log_message "检查规则库状态..."
        
        if [[ -d "$agent_rules_dir" ]]; then
            echo -e "${GREEN}✅ 规则库状态: 已部署${NC}"
            echo "   📁 位置: $agent_rules_dir"
            
            if [[ -d "$agent_rules_dir/.git" ]]; then
                cd "$agent_rules_dir"
                local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
                local last_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "unknown")
                echo "   🌿 分支: $current_branch"
                echo "   📝 最新提交: $last_commit"
                cd - > /dev/null
            fi
            
            local rule_count=$(find "$agent_rules_dir/project-rules" -name "*.mdc" 2>/dev/null | wc -l)
            echo "   📊 规则数量: $rule_count"
        else
            echo -e "${RED}❌ 规则库状态: 未部署${NC}"
            echo "   💡 运行 'grule --deploy' 进行首次部署"
        fi
        
        # 检查全局命令
        if [[ -f "$HOME/bin/grule" ]]; then
            echo -e "${GREEN}✅ 全局命令: 已安装${NC}"
        else
            echo -e "${YELLOW}⚠️  全局命令: 未安装${NC}"
        fi
    }

    # 更新规则库
    function update_rules() {
        local agent_rules_dir="$HOME/.agent-rules"
        
        log_message "更新规则库..."
        
        if [[ ! -d "$agent_rules_dir" ]]; then
            error_message "规则库未部署，请先运行 'grule --deploy'"
            return 1
        fi
        
        if [[ ! -d "$agent_rules_dir/.git" ]]; then
            warning_message "规则库不是Git仓库，无法更新"
            return 1
        fi
        
        cd "$agent_rules_dir"
        log_message "执行: git pull origin main"
        
        if git pull origin main 2>/dev/null; then
            success_message "规则库更新成功"
        else
            warning_message "更新失败，使用现有版本"
        fi
        
        cd - > /dev/null
    }

    # 部署规则库到本地
    function deploy_rules() {
        local agent_rules_dir="$HOME/.agent-rules"
        local custom_path="$1"
        
        log_message "开始部署规则库..."
        
        # 使用自定义路径或默认路径
        if [[ -n "$custom_path" ]]; then
            if [[ -d "$custom_path" ]]; then
                log_message "使用自定义路径: $custom_path"
                cp -r "$custom_path" "$agent_rules_dir"
                success_message "从自定义路径部署成功"
                return 0
            else
                error_message "自定义路径不存在: $custom_path"
                return 1
            fi
        fi
        
        # 从Git仓库部署
        if [[ -d "$agent_rules_dir" ]]; then
            if $force_mode; then
                log_message "强制模式: 删除现有规则库"
                rm -rf "$agent_rules_dir"
            else
                warning_message "规则库已存在，使用 --force 强制重新部署"
                return 1
            fi
        fi
        
        log_message "执行: git clone git@github.com:epodak/agent-rules.git $agent_rules_dir"
        
        if git clone "git@github.com:epodak/agent-rules.git" "$agent_rules_dir" 2>/dev/null; then
            success_message "SSH方式克隆成功"
        elif git clone "https://github.com/epodak/agent-rules.git" "$agent_rules_dir" 2>/dev/null; then
            success_message "HTTPS方式克隆成功"
        else
            error_message "克隆失败，请检查网络连接和仓库权限"
            return 1
        fi
        
        # 创建全局命令
        create_global_command
    }

    # 创建全局命令
    function create_global_command() {
        local bin_dir="$HOME/bin"
        local grule_script="$bin_dir/grule"
        
        log_message "创建全局命令..."
        
        mkdir -p "$bin_dir"
        
        cat > "$grule_script" << 'EOF'
#!/bin/bash
# Global Rules Command - Auto-generated
SCRIPT_DIR="$HOME/.agent-rules"
if [[ -f "$SCRIPT_DIR/grule.sh" ]]; then
    source "$SCRIPT_DIR/grule.sh"
    grule "$@"
else
    echo "错误: 规则库未找到，请运行部署命令"
    exit 1
fi
EOF
        
        chmod +x "$grule_script"
        success_message "全局命令创建成功: $grule_script"
        
        echo ""
        echo -e "${YELLOW}💡 手动添加到PATH:${NC}"
        echo "   echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc"
        echo "   source ~/.bashrc"
    }

    # 检测项目类型
    function detect_project_type() {
        local project_types=()
        
        log_message "分析项目结构..."
        
        # JavaScript项目检测
        if [[ -f "package.json" ]]; then
            project_types+=("javascript")
            echo "  ✓ JavaScript/Node.js项目 (package.json)"
            
            if grep -q "react" package.json 2>/dev/null; then
                project_types+=("react")
                echo "  ✓ React框架"
            fi
            if grep -q "vue" package.json 2>/dev/null; then
                project_types+=("vue")
                echo "  ✓ Vue框架"
            fi
        elif find . -maxdepth 2 -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -1 | grep -q "\.\(js\|ts\|jsx\|tsx\)$"; then
            project_types+=("javascript")
            echo "  ✓ JavaScript项目 (发现JS/TS文件)"
        fi
        
        # Python项目检测
        if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
            project_types+=("python")
            echo "  ✓ Python项目"
        fi
        
        # 其他项目类型
        [[ -f "Cargo.toml" ]] && { project_types+=("rust"); echo "  ✓ Rust项目"; }
        [[ -f "go.mod" ]] && { project_types+=("go"); echo "  ✓ Go项目"; }
        find . -maxdepth 2 -name "*.swift" -type f | head -1 | grep -q "swift" && { project_types+=("swift"); echo "  ✓ Swift项目"; }
        
        # 开发模式检测
        find . -maxdepth 3 -name "*.test.*" -o -name "*test*" -type f | head -1 | grep -q "test" && { project_types+=("testing"); echo "  ✓ 测试环境"; }
        [[ -d ".github" ]] || [[ -f ".gitlab-ci.yml" ]] && { project_types+=("ci_cd"); echo "  ✓ CI/CD配置"; }
        
        echo "${project_types[@]}"
    }

    # 推荐规则
    function recommend_rules() {
        local project_types=("$@")
        local recommended_rules=()
        
        # 核心规则
        recommended_rules+=("implement-task" "bug-fix" "check" "commit" "clean" "quick-wins")
        
        # 类型特定规则
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
        
        # 生产力规则
        recommended_rules+=("rule-effectiveness-tracker" "continuous-improvement")
        
        # 去重
        echo "${recommended_rules[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
    }

    # 安装规则到项目
    function install_rules() {
        local target="$1"
        local agent_rules_dir="$HOME/.agent-rules"
        
        log_message "在当前项目中安装规则..."
        
        if [[ ! -d "$agent_rules_dir" ]]; then
            error_message "规则库未部署，请先运行 'grule --deploy'"
            return 1
        fi
        
        # 检测项目类型
        local project_types=($(detect_project_type))
        if [[ ${#project_types[@]} -eq 0 ]]; then
            warning_message "未检测到特定项目类型，安装通用规则"
            project_types=("universal")
        fi
        
        # 获取推荐规则
        local recommended_rules=($(recommend_rules "${project_types[@]}"))
        
        echo ""
        echo -e "${GREEN}📋 推荐规则:${NC}"
        for rule in "${recommended_rules[@]}"; do
            echo "  • $rule"
        done
        echo ""
        
        # 安装到不同目标
        case "$target" in
            "cursor"|"both")
                install_cursor_rules "${recommended_rules[@]}"
                ;;
        esac
        
        case "$target" in
            "claude"|"both")
                install_claude_rules "${recommended_rules[@]}"
                ;;
        esac
        
        success_message "规则安装完成！"
    }

    # 安装Cursor规则
    function install_cursor_rules() {
        local rules=("$@")
        local cursor_dir=".cursor/rules"
        local agent_rules_dir="$HOME/.agent-rules"
        
        log_message "设置Cursor规则..."
        mkdir -p "$cursor_dir"
        
        local installed_count=0
        local missing_count=0
        
        for rule in "${rules[@]}"; do
            local rule_file="$agent_rules_dir/project-rules/${rule}.mdc"
            if [[ -f "$rule_file" ]]; then
                if $force_mode || [[ ! -f "$cursor_dir/${rule}.mdc" ]]; then
                    cp "$rule_file" "$cursor_dir/"
                    echo "  ✓ 安装: $rule.mdc"
                    ((installed_count++))
                else
                    echo "  ⚠ 跳过: $rule.mdc (已存在，使用--force强制覆盖)"
                fi
            else
                echo "  ❌ 缺失: $rule.mdc"
                ((missing_count++))
            fi
        done
        
        echo -e "${GREEN}📊 Cursor安装总结:${NC}"
        echo "  ✅ 已安装: $installed_count 个规则"
        [[ $missing_count -gt 0 ]] && echo -e "  ${YELLOW}⚠ 缺失: $missing_count 个规则${NC}"
    }

    # 安装Claude规则
    function install_claude_rules() {
        local rules=("$@")
        local claude_file="CLAUDE.md"
        local agent_rules_dir="$HOME/.agent-rules"
        
        log_message "设置Claude Code规则..."
        
        if [[ -f "$claude_file" ]] && ! $force_mode; then
            warning_message "$claude_file 已存在，使用--force强制覆盖"
            return 1
        fi
        
        if [[ -f "$claude_file" ]]; then
            local backup_file="${claude_file}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$claude_file" "$backup_file"
            log_message "备份现有文件: $backup_file"
        fi
        
        cat > "$claude_file" << 'EOF'
# Claude Code Rules

AI助手规则 - 由grule工具自动生成
Generated by grule tool

EOF
        
        local added_count=0
        for rule in "${rules[@]}"; do
            local rule_file="$agent_rules_dir/project-rules/${rule}.mdc"
            if [[ -f "$rule_file" ]]; then
                echo "## $rule" >> "$claude_file"
                sed '1,/^---$/d; /^---$/,$ d' "$rule_file" >> "$claude_file"
                echo "" >> "$claude_file"
                echo "  ✓ 添加: $rule"
                ((added_count++))
            fi
        done
        
        echo -e "${GREEN}📊 Claude Code安装总结:${NC}"
        echo "  ✅ 已添加: $added_count 个规则"
    }

    # 默认参数
    local action=""
    local target="both"
    local custom_path=""
    local force_mode=false
    local log_enabled=false

    # 参数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--deploy)
                action="deploy"
                shift
                ;;
            -i|--install)
                action="install"
                shift
                ;;
            -u|--update)
                action="update"
                shift
                ;;
            -s|--status)
                action="status"
                shift
                ;;
            -p|--path)
                if [[ -n "$2" && "$2" != -* ]]; then
                    custom_path="$2"
                    shift 2
                else
                    error_message "-p|--path 选项需要一个路径值"
                    show_help
                    return 1
                fi
                ;;
            -t|--target)
                if [[ -n "$2" && "$2" != -* ]]; then
                    case "$2" in
                        cursor|claude|both)
                            target="$2"
                            shift 2
                            ;;
                        *)
                            error_message "无效的目标类型: $2 (支持: cursor|claude|both)"
                            return 1
                            ;;
                    esac
                else
                    error_message "-t|--target 选项需要一个值 (cursor|claude|both)"
                    show_help
                    return 1
                fi
                ;;
            -f|--force)
                force_mode=true
                shift
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            -l|--log)
                log_enabled=true
                shift
                ;;
            *)
                error_message "无效的选项: $1"
                show_help
                return 1
                ;;
        esac
    done

    # 执行相应动作
    case "$action" in
        "deploy")
            log_message "执行部署操作..."
            deploy_rules "$custom_path"
            ;;
        "install")
            log_message "执行安装操作，目标: $target"
            install_rules "$target"
            ;;
        "update")
            log_message "执行更新操作..."
            update_rules
            ;;
        "status")
            check_rules_status
            ;;
        "")
            error_message "必须指定一个操作 (--deploy|--install|--update|--status)"
            show_help
            return 1
            ;;
        *)
            error_message "未知操作: $action"
            show_help
            return 1
            ;;
    esac
}

# 如果直接运行脚本，执行grule函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    grule "$@"
fi 