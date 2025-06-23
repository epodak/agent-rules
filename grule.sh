#!/bin/bash

# Global Rules (grule) - AI Rules Management Tool
# Deploy and manage AI assistant rules across projects

# 移除 set -e 避免终端退出问题
# set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

function grule() {
    # 显示帮助信息
    function show_help() {
        cat << 'EOF'
grule - 智能AI助手规则管理工具

用法: grule [选项]

基础操作:
    -d, --deploy           部署规则库到本地系统
    -i, --install          在当前项目中安装规则
    -u, --update           更新本地规则库
    -s, --status           显示规则库状态

规则管理:
    --add-rule <名称>      创建新的自定义规则
    --list-rules           列出所有可用规则
    --rule-info <名称>     显示规则详细信息

配置选项:
    -p, --path <路径>      指定自定义规则库路径
    -t, --target <目标>    指定安装目标 (cursor|claude|both)
    -f, --force            强制执行操作
    -l, --log              启用详细日志
    -h, --help             显示此帮助信息

示例:
    grule                         # 智能模式：自动分析环境并执行最合适的操作
    grule --deploy                # 首次部署规则库
    grule --install               # 在项目中安装推荐规则
    grule --update                # 更新规则库到最新版本
    grule --status                # 查看当前状态
    
    grule --list-rules            # 查看所有可用规则
    grule --add-rule api-security # 创建API安全规则
    grule --rule-info modern-swift # 查看Swift规则详情
    
智能特性:
    • 🔍 深度项目分析：检测语言、框架、团队规模、项目成熟度
    • 🧠 智能规则推荐：基于项目特征匹配最相关的规则
    • 📊 效果追踪：量化规则使用效果和ROI
    • 🔧 可扩展性：支持自定义规则和条件配置
    • 👥 团队协作：支持个人和团队开发模式

配置文件:
    ~/.agent-rules/rule-config.json  # 规则配置和智能匹配条件

EOF
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
        
        # 创建配置文件
        create_config_file
        
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
    
    # 创建配置文件
    function create_config_file() {
        local agent_rules_dir="$HOME/.agent-rules"
        local config_file="$agent_rules_dir/rule-config.json"
        
        if [[ -f "$config_file" ]] && ! $force_mode; then
            log_message "配置文件已存在，跳过创建"
            return 0
        fi
        
        log_message "创建智能推荐配置文件..."
        
        # 复制配置文件模板
        if [[ -f "rule-config.json" ]]; then
            cp "rule-config.json" "$config_file"
            success_message "配置文件创建成功: $config_file"
        else
            warning_message "配置文件模板不存在，使用默认推荐逻辑"
        fi
    }

    # 深度项目分析
    function analyze_project() {
        local analysis_result=()
        
        log_message "🔍 深度分析项目特征..."
        
        # 1. 项目规模分析
        local file_count=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.swift" -o -name "*.java" -o -name "*.cs" \) 2>/dev/null | wc -l)
        local line_count=0
        if [[ $file_count -gt 0 ]]; then
            line_count=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.swift" -o -name "*.java" -o -name "*.cs" \) -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' 2>/dev/null || echo "0")
        fi
        
        if [[ $file_count -gt 50 ]] || [[ $line_count -gt 10000 ]]; then
            analysis_result+=("project_size:large")
            echo "  📊 大型项目 ($file_count 文件, ~$line_count 行代码)"
        elif [[ $file_count -gt 10 ]] || [[ $line_count -gt 1000 ]]; then
            analysis_result+=("project_size:medium")
            echo "  📊 中型项目 ($file_count 文件, ~$line_count 行代码)"
        else
            analysis_result+=("project_size:small")
            echo "  📊 小型项目 ($file_count 文件, ~$line_count 行代码)"
        fi
        
        # 2. 语言检测
        local detected_languages=()
        [[ -f "package.json" ]] && detected_languages+=("javascript")
        [[ -f "tsconfig.json" ]] || find . -name "*.ts" -o -name "*.tsx" | head -1 | grep -q "ts" && detected_languages+=("typescript")
        [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] && detected_languages+=("python")
        [[ -f "Cargo.toml" ]] && detected_languages+=("rust")
        [[ -f "go.mod" ]] && detected_languages+=("go")
        find . -name "*.swift" | head -1 | grep -q "swift" && detected_languages+=("swift")
        [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]] && detected_languages+=("java")
        find . -name "*.cs" -o -name "*.csproj" | head -1 | grep -q "cs" && detected_languages+=("csharp")
        
        for lang in "${detected_languages[@]}"; do
            analysis_result+=("languages:$lang")
            echo "  🔤 检测到语言: $lang"
        done
        
        # 3. 框架检测
        if [[ -f "package.json" ]]; then
            grep -q "react\|next" package.json 2>/dev/null && { analysis_result+=("frameworks:react"); echo "  ⚛️ React框架"; }
            grep -q "vue\|@vue" package.json 2>/dev/null && { analysis_result+=("frameworks:vue"); echo "  🟢 Vue框架"; }
            grep -q "express" package.json 2>/dev/null && { analysis_result+=("frameworks:express"); echo "  🚀 Express框架"; }
        fi
        
        if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
            grep -q "django" requirements.txt pyproject.toml 2>/dev/null && { analysis_result+=("frameworks:django"); echo "  🎸 Django框架"; }
            grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null && { analysis_result+=("frameworks:fastapi"); echo "  ⚡ FastAPI框架"; }
            grep -q "flask" requirements.txt pyproject.toml 2>/dev/null && { analysis_result+=("frameworks:flask"); echo "  🌶️ Flask框架"; }
        fi
        
        # 4. 团队规模分析
        if [[ -d ".git" ]]; then
            local contributor_count=$(git log --format='%ae' 2>/dev/null | sort -u | wc -l 2>/dev/null || echo "1")
            if [[ $contributor_count -gt 10 ]]; then
                analysis_result+=("team_size:large")
                echo "  👥 大型团队 ($contributor_count 贡献者)"
            elif [[ $contributor_count -gt 3 ]]; then
                analysis_result+=("team_size:medium")
                echo "  👥 中型团队 ($contributor_count 贡献者)"
            elif [[ $contributor_count -gt 1 ]]; then
                analysis_result+=("team_size:small")
                echo "  👥 小型团队 ($contributor_count 贡献者)"
            else
                analysis_result+=("team_size:solo")
                echo "  👤 个人项目 ($contributor_count 贡献者)"
            fi
            
            # 项目成熟度
            local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
            if [[ $commit_count -gt 100 ]]; then
                analysis_result+=("project_maturity:mature")
                echo "  🎯 成熟项目 ($commit_count 提交)"
            elif [[ $commit_count -gt 10 ]]; then
                analysis_result+=("project_maturity:developing")
                echo "  🌱 开发中项目 ($commit_count 提交)"
            else
                analysis_result+=("project_maturity:new")
                echo "  🆕 新项目 ($commit_count 提交)"
            fi
            
            analysis_result+=("has_git:true")
        else
            analysis_result+=("has_git:false")
        fi
        
        # 5. 工具链检测
        find . -name "*test*" -o -name "*.test.*" | head -1 | grep -q "test" && { analysis_result+=("has_testing:true"); echo "  🧪 包含测试"; }
        [[ -d ".github/workflows" ]] || [[ -f ".gitlab-ci.yml" ]] && { analysis_result+=("has_cicd:true"); echo "  🔄 配置CI/CD"; }
        [[ -f "Dockerfile" ]] && { analysis_result+=("has_docker:true"); echo "  🐳 容器化项目"; }
        [[ -f "README.md" ]] && [[ $(wc -l < README.md 2>/dev/null || echo "0") -gt 20 ]] && { analysis_result+=("has_documentation:true"); echo "  📚 文档完善"; }
        
        echo "${analysis_result[@]}"
    }

    # 智能规则推荐引擎
    function recommend_rules_intelligently() {
        local project_features=("$@")
        local agent_rules_dir="$HOME/.agent-rules"
        local config_file="$agent_rules_dir/rule-config.json"
        local recommended_rules=()
        local reasoning=()
        
        log_message "🧠 启动智能规则推荐引擎..."
        
        # 如果没有配置文件，使用默认逻辑
        if [[ ! -f "$config_file" ]]; then
            warning_message "规则配置文件不存在，使用默认推荐逻辑"
            local fallback_rules=($(recommend_rules_fallback "${project_features[@]}"))
            echo "${fallback_rules[@]}"
            return
        fi
        
        # 解析项目特征
        local -A project_attrs
        for feature in "${project_features[@]}"; do
            if [[ "$feature" == *":"* ]]; then
                local key="${feature%%:*}"
                local value="${feature##*:}"
                project_attrs["$key"]="$value"
            else
                project_attrs["$feature"]="true"
            fi
        done
        
        echo ""
        echo -e "${BLUE}📊 项目特征分析:${NC}"
        for key in "${!project_attrs[@]}"; do
            echo "  • $key: ${project_attrs[$key]}"
        done
        echo ""
        
        # 读取并评估规则
        echo -e "${GREEN}🎯 规则匹配分析:${NC}"
        
        # 核心规则（总是推荐）
        recommended_rules+=("implement-task" "bug-fix" "quick-wins")
        reasoning+=("核心开发流程规则 - 所有项目必需")
        
        # 基于项目规模
        case "${project_attrs[project_size]}" in
            "large")
                recommended_rules+=("code-analysis" "pr-review" "continuous-improvement")
                reasoning+=("大型项目需要严格的代码质量控制和协作流程")
                ;;
            "medium")
                recommended_rules+=("code-analysis" "check")
                reasoning+=("中型项目需要代码质量检查")
                ;;
            "small")
                recommended_rules+=("clean" "commit")
                reasoning+=("小型项目重点关注代码整洁和提交规范")
                ;;
        esac
        
        # 基于语言特定规则
        for lang in javascript typescript python swift java csharp rust go; do
            if [[ "${project_attrs[languages]}" == *"$lang"* ]]; then
                case $lang in
                    "swift")
                        recommended_rules+=("modern-swift")
                        reasoning+=("Swift项目需要现代Swift开发规范")
                        ;;
                    "javascript"|"typescript")
                        recommended_rules+=("code-analysis")
                        reasoning+=("JavaScript/TypeScript项目需要代码分析")
                        ;;
                    "python"|"java"|"csharp")
                        recommended_rules+=("code-analysis")
                        reasoning+=("$lang项目需要代码质量分析")
                        ;;
                esac
            fi
        done
        
        # 基于框架特定规则
        for framework in react vue django fastapi flask express; do
            if [[ "${project_features[*]}" == *"frameworks:$framework"* ]]; then
                case $framework in
                    "django"|"fastapi"|"flask"|"express")
                        # 这里可以添加自定义规则
                        echo "  🌐 检测到$framework框架 - 可添加API安全规则"
                        ;;
                esac
            fi
        done
        
        # 基于团队规模
        case "${project_attrs[team_size]}" in
            "large"|"medium")
                recommended_rules+=("pr-review" "add-to-changelog")
                reasoning+=("团队项目需要代码审查和变更记录")
                ;;
            "small"|"solo")
                # 个人或小团队项目的特定规则
                echo "  👤 小团队项目 - 简化流程"
                ;;
        esac
        
        # 基于项目成熟度
        case "${project_attrs[project_maturity]}" in
            "mature")
                recommended_rules+=("continuous-improvement")
                reasoning+=("成熟项目需要持续改进")
                ;;
            "new")
                # 新项目的特定建议
                echo "  🌱 新项目 - 建立基础规范"
                ;;
        esac
        
        # 基于工具链
        [[ "${project_attrs[has_testing]}" == "true" ]] && {
            recommended_rules+=("five")
            reasoning+=("已有测试框架，增强测试质量")
        }
        
        [[ "${project_attrs[has_git]}" == "true" ]] && {
            recommended_rules+=("commit")
            reasoning+=("Git项目需要提交规范")
        }
        
        # 添加效果追踪
        recommended_rules+=("rule-effectiveness-tracker")
        reasoning+=("跟踪规则使用效果")
        
        # 去重并输出
        local unique_rules=($(printf '%s\n' "${recommended_rules[@]}" | sort -u))
        
        echo ""
        echo -e "${GREEN}📋 智能推荐结果:${NC}"
        local i=0
        for rule in "${unique_rules[@]}"; do
            echo "  ✓ $rule"
            if [[ $i -lt ${#reasoning[@]} ]]; then
                echo -e "    ${GRAY}💡 ${reasoning[$i]}${NC}"
            fi
            ((i++))
        done
        
        echo ""
        echo -e "${BLUE}📊 推荐统计:${NC}"
        echo "  • 推荐规则数: ${#unique_rules[@]}"
        echo "  • 匹配特征数: ${#project_features[@]}"
        echo "  • 智能度评分: $((${#unique_rules[@]} * 10 / (${#project_features[@]} + 1)))%"
        
        echo "${unique_rules[@]}"
    }
    
    # 备用推荐逻辑
    function recommend_rules_fallback() {
        local project_features=("$@")
        local recommended_rules=()
        
        warning_message "使用备用推荐逻辑"
        
        # 基础规则
        recommended_rules+=("implement-task" "bug-fix" "quick-wins" "clean" "commit")
        
        # 简单特征匹配
        for feature in "${project_features[@]}"; do
            case $feature in
                *"swift"*)
                    recommended_rules+=("modern-swift")
                    ;;
                *"large"*)
                    recommended_rules+=("code-analysis" "pr-review")
                    ;;
                *"testing"*)
                    recommended_rules+=("five")
                    ;;
            esac
        done
        
        recommended_rules+=("rule-effectiveness-tracker")
        
        # 去重
        local unique_rules=($(printf '%s\n' "${recommended_rules[@]}" | sort -u))
        echo "${unique_rules[@]}"
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
        
        # 深度分析项目
        local project_features=($(analyze_project))
        if [[ ${#project_features[@]} -eq 0 ]]; then
            warning_message "未检测到项目特征，使用默认规则"
            project_features=("project_size:small")
        fi
        
        # 获取智能推荐规则
        local recommended_rules=($(recommend_rules_intelligently "${project_features[@]}"))
        
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

    # 智能默认行为
    function smart_default_action() {
        local agent_rules_dir="$HOME/.agent-rules"
        
        echo -e "${BLUE}🤖 智能模式 - 自动分析环境...${NC}"
        echo ""
        
        # 检查规则库是否存在
        if [[ ! -d "$agent_rules_dir" ]]; then
            echo -e "${YELLOW}📦 规则库未部署，执行首次部署...${NC}"
            deploy_rules ""
            return $?
        fi
        
        # 检查是否在项目目录中
        local is_project=false
        
        # 检查明确的项目标识文件
        if [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "Cargo.toml" ]] || [[ -f "go.mod" ]] || [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
            is_project=true
        fi
        
        # 检查是否有源代码文件（至少2个）
        if ! $is_project; then
            local code_files=$(find . -maxdepth 2 -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.swift" -o -name "*.rs" -o -name "*.go" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" 2>/dev/null | wc -l)
            if [[ $code_files -ge 2 ]]; then
                is_project=true
            fi
        fi
        
        if $is_project; then
            echo -e "${GREEN}🎯 检测到项目环境，安装规则到当前项目...${NC}"
            install_rules "$target"
            return $?
        fi
        
        # 如果都不是，显示状态
        echo -e "${BLUE}📊 显示当前状态...${NC}"
        check_rules_status
        echo ""
        echo -e "${YELLOW}💡 提示:${NC}"
        echo "  • 在项目目录中运行可自动安装规则"
        echo "  • 使用 'grule --help' 查看所有选项"
        echo "  • 使用 'grule --update' 更新规则库"
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

    # 添加自定义规则
    function add_custom_rule() {
        local rule_name="$1"
        local agent_rules_dir="$HOME/.agent-rules"
        local config_file="$agent_rules_dir/rule-config.json"
        
        log_message "添加自定义规则: $rule_name"
        
        if [[ ! -d "$agent_rules_dir" ]]; then
            error_message "规则库未部署，请先运行 'grule --deploy'"
            return 1
        fi
        
        # 检查规则是否已存在
        if [[ -f "$agent_rules_dir/project-rules/${rule_name}.mdc" ]]; then
            if ! $force_mode; then
                warning_message "规则 $rule_name 已存在，使用 --force 强制覆盖"
                return 1
            fi
        fi
        
        echo "📝 创建新规则: $rule_name"
        echo ""
        
        # 交互式创建规则
        echo "请输入规则描述 (按Enter结束):"
        read -r rule_description
        
        echo "请选择规则类别:"
        echo "1) core - 核心规则"
        echo "2) quality - 质量规则" 
        echo "3) productivity - 生产力规则"
        echo "4) collaboration - 协作规则"
        echo "5) security - 安全规则"
        echo "6) custom - 自定义类别"
        read -r category_choice
        
        local category
        case $category_choice in
            1) category="core" ;;
            2) category="quality" ;;
            3) category="productivity" ;;
            4) category="collaboration" ;;
            5) category="security" ;;
            6) category="custom" ;;
            *) category="custom" ;;
        esac
        
        echo "请输入适用条件 (例如: python,large_project 或 回车跳过):"
        read -r conditions
        
        echo "请输入规则权重 (1-10, 默认5):"
        read -r weight
        [[ -z "$weight" ]] && weight=5
        
        # 创建规则文件
        local rule_file="$agent_rules_dir/project-rules/${rule_name}.mdc"
        cat > "$rule_file" << EOF
---
title: "$rule_name"
description: "$rule_description"
category: "$category"
weight: $weight
conditions: "$conditions"
---

# $rule_name

## 描述
$rule_description

## 适用场景
$conditions

## 实施指南
请在此处添加具体的实施指南和最佳实践。

## 示例
请在此处添加具体示例。

## 检查清单
- [ ] 检查项目1
- [ ] 检查项目2
- [ ] 检查项目3

EOF
        
        success_message "规则创建成功: $rule_file"
        echo ""
        echo -e "${YELLOW}💡 下一步:${NC}"
        echo "  • 编辑规则文件: $rule_file"
        echo "  • 运行 'grule --rule-info $rule_name' 查看规则信息"
        echo "  • 运行 'grule --install' 在项目中应用规则"
    }
    
    # 列出所有规则
    function list_all_rules() {
        local agent_rules_dir="$HOME/.agent-rules"
        
        log_message "列出所有可用规则"
        
        if [[ ! -d "$agent_rules_dir" ]]; then
            error_message "规则库未部署，请先运行 'grule --deploy'"
            return 1
        fi
        
        echo -e "${GREEN}📋 可用规则列表:${NC}"
        echo ""
        
        local rule_count=0
        for rule_file in "$agent_rules_dir/project-rules"/*.mdc; do
            if [[ -f "$rule_file" ]]; then
                local rule_name=$(basename "$rule_file" .mdc)
                local description=$(grep "^description:" "$rule_file" 2>/dev/null | cut -d'"' -f2 || echo "无描述")
                local category=$(grep "^category:" "$rule_file" 2>/dev/null | cut -d'"' -f2 || echo "未分类")
                
                echo "  📄 $rule_name"
                echo "     🏷️  类别: $category"
                echo "     📝 描述: $description"
                echo ""
                ((rule_count++))
            fi
        done
        
        echo -e "${BLUE}📊 统计信息:${NC}"
        echo "  • 总规则数: $rule_count"
        echo "  • 规则目录: $agent_rules_dir/project-rules"
        echo ""
        echo -e "${YELLOW}💡 使用提示:${NC}"
        echo "  • 查看规则详情: grule --rule-info <规则名>"
        echo "  • 添加自定义规则: grule --add-rule <规则名>"
    }
    
    # 显示规则信息
    function show_rule_info() {
        local rule_name="$1"
        local agent_rules_dir="$HOME/.agent-rules"
        local rule_file="$agent_rules_dir/project-rules/${rule_name}.mdc"
        
        log_message "显示规则信息: $rule_name"
        
        if [[ ! -f "$rule_file" ]]; then
            error_message "规则不存在: $rule_name"
            echo ""
            echo -e "${YELLOW}💡 提示:${NC}"
            echo "  • 使用 'grule --list-rules' 查看所有可用规则"
            echo "  • 使用 'grule --add-rule $rule_name' 创建新规则"
            return 1
        fi
        
        echo -e "${GREEN}📄 规则信息: $rule_name${NC}"
        echo "================================"
        
        # 提取规则元数据
        local description=$(grep "^description:" "$rule_file" 2>/dev/null | cut -d'"' -f2 || echo "无描述")
        local category=$(grep "^category:" "$rule_file" 2>/dev/null | cut -d'"' -f2 || echo "未分类")
        local weight=$(grep "^weight:" "$rule_file" 2>/dev/null | awk '{print $2}' || echo "未设置")
        local conditions=$(grep "^conditions:" "$rule_file" 2>/dev/null | cut -d'"' -f2 || echo "无限制")
        
        echo "🏷️  类别: $category"
        echo "📝 描述: $description"
        echo "⚖️  权重: $weight"
        echo "🎯 适用条件: $conditions"
        echo "📁 文件路径: $rule_file"
        echo ""
        
        # 显示规则内容预览
        echo -e "${BLUE}📖 内容预览:${NC}"
        echo "---"
        sed -n '/^---$/,/^---$/d; /^#/,/^$/p' "$rule_file" | head -20
        echo "---"
        echo ""
        
        # 智能匹配分析
        echo -e "${YELLOW}🧠 智能匹配分析:${NC}"
        local current_features=($(analyze_project 2>/dev/null))
        local matches=0
        
        if [[ "$conditions" != "无限制" && "$conditions" != "" ]]; then
            for condition in ${conditions//,/ }; do
                for feature in "${current_features[@]}"; do
                    if [[ "$feature" == *"$condition"* ]]; then
                        echo "  ✅ 匹配条件: $condition"
                        ((matches++))
                    fi
                done
            done
        else
            echo "  🌟 通用规则 - 适用于所有项目"
            matches=1
        fi
        
        if [[ $matches -gt 0 ]]; then
            echo -e "  ${GREEN}🎯 推荐指数: 高 (当前项目适用)${NC}"
        else
            echo -e "  ${YELLOW}⚠️  推荐指数: 低 (当前项目可能不适用)${NC}"
        fi
    }

    # 默认参数
    local action=""
    local target="both"
    local custom_path=""
    local rule_name=""
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
            --add-rule)
                action="add_rule"
                if [[ -n "$2" && "$2" != -* ]]; then
                    rule_name="$2"
                    shift 2
                else
                    error_message "--add-rule 选项需要规则名称"
                    show_help
                    return 1
                fi
                ;;
            --list-rules)
                action="list_rules"
                shift
                ;;
            --rule-info)
                action="rule_info"
                if [[ -n "$2" && "$2" != -* ]]; then
                    rule_name="$2"
                    shift 2
                else
                    error_message "--rule-info 选项需要规则名称"
                    show_help
                    return 1
                fi
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
        "add_rule")
            if [[ -z "$rule_name" ]]; then
                error_message "缺少规则名称"
                show_help
                return 1
            fi
            add_custom_rule "$rule_name"
            ;;
        "list_rules")
            list_all_rules
            ;;
        "rule_info")
            if [[ -z "$rule_name" ]]; then
                error_message "缺少规则名称"
                show_help
                return 1
            fi
            show_rule_info "$rule_name"
            ;;
        "")
            # 默认智能行为：根据环境自动选择最合适的操作
            smart_default_action
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