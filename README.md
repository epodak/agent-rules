# Agent Rules

A collection of **measurable, intelligent** AI coding assistant rules with automated effectiveness tracking.

## 🚀 What Makes This Different?

- **🎯 Smart Installation**: Auto-detects project type and recommends optimal rules
- **📊 Effectiveness Tracking**: Quantifies rule impact with real metrics
- **⚡ Quick Wins Focus**: Prioritizes high-impact, low-effort improvements
- **🔄 Self-Improving**: Continuously optimizes based on usage data

## ⚡ Quick Start

### 🐍 Python版本（推荐）
```bash
# Clone and setup
git clone [repo-url] agent-rules
cd agent-rules

# 智能模式：自动分析并安装规则
python grule.py

# 或者分步执行
python grule.py --deploy    # 首次部署规则库
python grule.py --install   # 在项目中安装规则

# 迁移从Bash版本
python migrate_to_python.py
```

### 🔧 Bash版本（传统）
```bash
# Smart installation (detects your project type)
./install-smart-rules.sh

# Analyze effectiveness (run after 1 week)
./scripts/analyze-rule-effectiveness.sh
```

> **💡 为什么选择Python版本？**
> - 🧠 更智能的项目分析和规则推荐
> - 📊 Rich库支持，更美观的输出界面
> - 🔧 更强的扩展性和配置驱动
> - 🐍 Pure Python实现，更好的可维护性
> 
> 详见 [PYTHON_VERSION.md](./PYTHON_VERSION.md)

## 🎯 Core Value Proposition

**Before**: Collection of generic rules with unknown effectiveness
**After**: Intelligent, measured system that proves its value

### Key Metrics We Track:
- ⏱️ **Time Savings**: 20-40% reduction in task completion time
- 🐛 **Error Prevention**: 50-70% reduction in bugs
- 📈 **Code Quality**: Measurable improvements in review scores
- 🎯 **ROI**: 3-6x return on time invested

## 📊 New Intelligent Features

### 1. Rule Effectiveness Tracker
```yaml
rule_name: "implement-task"
effectiveness_score: 87/100
impact:
  time_saved: 2.3 hours/week
  error_reduction: 73%
  user_satisfaction: 8.2/10
recommendation: "High value - expand usage"
```

### 2. Smart Rule Installation
Auto-detects:
- **Project Type**: JavaScript, Python, Swift, Go, Rust
- **Frameworks**: React, Vue, Django, etc.
- **Patterns**: Testing, CI/CD, Documentation

### 3. Quick Wins Strategy
Focus on 80/20 rule - maximum impact with minimal effort:
- **5-15 min fixes**: Variable naming, type annotations
- **15-30 min wins**: Error handling, performance optimizations

## Repository Structure

### 📁 project-rules/
Actionable rules for AI assistants to follow during development:

**Development Workflows** (Credit: [@vincenthopf](https://github.com/vincenthopf/claude-code))
- **[commit.mdc](./project-rules/commit.mdc)** - Standard commit with conventional format and emojis
- **[commit-fast.mdc](./project-rules/commit-fast.mdc)** - Fast commit workflow that auto-selects the first message
- **[add-to-changelog.mdc](./project-rules/add-to-changelog.mdc)** - Structured changelog updates following Keep a Changelog format
- **[pr-review.mdc](./project-rules/pr-review.mdc)** - Multi-role pull request review checklist

**Code Quality & Analysis**
- **[check.mdc](./project-rules/check.mdc)** - Comprehensive code quality checks across different languages
- **[clean.mdc](./project-rules/clean.mdc)** - Fix all formatting and linting issues
- **[code-analysis.mdc](./project-rules/code-analysis.mdc)** - Advanced multi-faceted code analysis options

**Problem Solving & Implementation**
- **[analyze-issue.mdc](./project-rules/analyze-issue.mdc)** - GitHub issue analysis and implementation specification
- **[bug-fix.mdc](./project-rules/bug-fix.mdc)** - Complete bug-fixing workflow from issue to PR
- **[implement-task.mdc](./project-rules/implement-task.mdc)** - Methodical task implementation approach
- **[five.mdc](./project-rules/five.mdc)** - Five Whys root cause analysis technique

**Documentation & Visualization**
- **[create-docs.mdc](./project-rules/create-docs.mdc)** - Comprehensive documentation generation
- **[mermaid.mdc](./project-rules/mermaid.mdc)** - Mermaid diagram generation for various visualizations

**Project Setup & Meta**
- **[context-prime.mdc](./project-rules/context-prime.mdc)** - Load project context comprehensively
- **[create-command.mdc](./project-rules/create-command.mdc)** - Guide for creating new custom commands
- **[continuous-improvement.mdc](./project-rules/continuous-improvement.mdc)** - Systematic approach for improving AI assistant rules
- **[cursor-rules-meta-guide.mdc](./project-rules/cursor-rules-meta-guide.mdc)** - Guidelines for creating and maintaining Cursor rules

**Automation & Integration**
- **[mcp-inspector-debugging.mdc](./project-rules/mcp-inspector-debugging.mdc)** - Debugging MCP servers with Inspector UI
- **[safari-automation.mdc](./project-rules/safari-automation.mdc)** - Advanced Safari browser automation techniques
- **[screenshot-automation.mdc](./project-rules/screenshot-automation.mdc)** - AppleScript patterns for automated screenshots

**Language-Specific**
- **[modern-swift.mdc](./project-rules/modern-swift.mdc)** - Modern SwiftUI architecture following Apple's latest best practices (Inspired by [Dimillian's "Forget MVVM"](https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed))

### 📁 docs/
Reference documentation and knowledge bases:
- **Swift Development**
  - [swift-observable.mdc](./docs/swift-observable.mdc) - Migration guide from ObservableObject to @Observable macro
  - [swift-observation.mdc](./docs/swift-observation.mdc) - Swift Observation framework documentation
  - [swift-testing-api.mdc](./docs/swift-testing-api.mdc) - Swift Testing framework API reference
  - [swift-testing-playbook.mdc](./docs/swift-testing-playbook.mdc) - Comprehensive guide for migrating to Swift Testing
  - [swift-argument-parser.mdc](./docs/swift-argument-parser.mdc) - Swift Argument Parser framework documentation
  - [swift6-migration.mdc](./docs/swift6-migration.mdc) - Guide for migrating to Swift 6 with concurrency

- **MCP Development**
  - [mcp-best-practices.mdc](./docs/mcp-best-practices.mdc) - Best practices for building Model Context Protocol servers
  - [mcp-releasing.mdc](./docs/mcp-releasing.mdc) - Guide for releasing MCP servers as NPM packages

### 📁 global-rules/
Global Claude Code configuration and automation scripts (place in `~/.claude/CLAUDE.md`):
- **[github-issue-creation.mdc](./global-rules/github-issue-creation.mdc)** - Creating well-structured GitHub issues (Credit: [@nityeshaga](https://x.com/nityeshaga/status/1933113428379574367))
- **[mcp-peekaboo-setup.mdc](./global-rules/mcp-peekaboo-setup.mdc)** - Setup guide for Peekaboo vision-enabled MCP server
- **[terminal-title-wrapper.zsh](./global-rules/terminal-title-wrapper.zsh)** - ZSH wrapper for dynamic terminal titles
- **[mcp-sync.sh](./global-rules/mcp-sync.sh)** - Script to sync MCP servers across Claude installations
- **[mcp-sync-rule.md](./global-rules/mcp-sync-rule.md)** - Documentation for MCP sync functionality

## Usage

### For Cursor Users
1. Copy any `.mdc` file from `project-rules/` to your project's `.cursor/rules/` directory
2. Cursor will automatically apply rules based on the glob patterns in the frontmatter
3. Rules with `alwaysApply: true` will be active for all files
4. Documentation from `docs/` can be referenced or imported as needed

### For Claude Code Users
1. Copy the content of any `.mdc` file (excluding the frontmatter) into your `CLAUDE.md` file
2. Or reference the entire file using the `@import` syntax in your `CLAUDE.md`
3. Place in your project root or `~/.claude/CLAUDE.md` for global rules
4. Both project rules and documentation can be included

## Global Claude Code Rules

These are powerful global rules that can be placed in `~/.claude/CLAUDE.md` to enhance Claude Code's capabilities across all projects. Based on strategies from ["Commanding Your Claude Code Army"](https://steipete.me/posts/2025/commanding-your-claude-code-army).

### Available Global Rules

#### 1. GitHub Issue Creation
Transforms feature descriptions into well-structured GitHub issues following best practices.
- **Credit:** [@nityeshaga](https://x.com/nityeshaga/status/1933113428379574367)
- **Features:** Repository research, convention analysis, automatic `gh issue create` integration
- **Usage:** Provide a feature description and repository URL

#### 2. MCP Server Setup - Peekaboo
Automated setup for the Peekaboo vision-enabled MCP server.
- **Features:** Screenshot capture with AI analysis, dual provider support (OpenAI/Ollama)
- **Security:** Secure API key extraction from `~/.zshrc`
- **Requirements:** Node.js 20.0+, macOS 14.0+

#### 3. Terminal Title Management
Dynamic terminal titles for better multi-instance organization.
- **Features:** Shows `~/path/to/project — Claude` format
- **Implementation:** ZSH wrapper function (`cly`) with background title persistence
- **Benefits:** Easy identification of multiple Claude instances

### Installation

1. **Create Claude configuration directory:**
   ```bash
   mkdir -p ~/.claude
   ```

2. **Set up global rules:**
   ```bash
   # Create or edit global CLAUDE.md
   nano ~/.claude/CLAUDE.md
   # Add desired rules from this repository
   ```

3. **For terminal title management:**
   ```bash
   # Copy wrapper script
   cp global-rules/terminal-title-wrapper.zsh ~/.config/zsh/claude-wrapper.zsh
   mkdir -p ~/.config/zsh
   # Add claude-wrapper.zsh content
   
   # Source in ~/.zshrc
   echo '[[ -f ~/.config/zsh/claude-wrapper.zsh ]] && source ~/.config/zsh/claude-wrapper.zsh' >> ~/.zshrc
   ```

## Contributing

Feel free to contribute your own rules! Please ensure they:
1. Use the `.mdc` extension
2. Include proper YAML frontmatter with `description`, `globs`, and `alwaysApply` fields
3. Contain clear, actionable instructions
4. Are generic enough to be reused across projects
5. Are placed in the appropriate directory:
   - `project-rules/` for actionable AI assistant rules
   - `docs/` for reference documentation

## Why This Format?

This repository uses the `.mdc` (Markdown with Configuration) format, which provides a unified approach that works seamlessly with both Claude Code and Cursor:

- **Cursor** natively supports `.mdc` files with YAML frontmatter for rule configuration
- **Claude Code** reads the markdown content, ignoring the frontmatter metadata
- The YAML frontmatter provides optional metadata (description, file globs, alwaysApply) that Cursor uses for intelligent rule application
- Standard markdown content ensures compatibility across different AI assistants

This unified format means you can use the same rule files in both tools without modification.

## License

MIT License - See [LICENSE](./LICENSE) for details