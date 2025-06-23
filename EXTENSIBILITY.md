# grule 扩展性指南

## 🎯 概述

grule工具设计为高度可扩展的智能规则管理系统。您可以轻松添加新规则、自定义智能判断逻辑，并根据项目特征进行个性化推荐。

## 📋 快速添加规则

### 1. 命令行添加规则

```bash
# 交互式创建新规则
grule --add-rule api-security

# 强制覆盖现有规则
grule --add-rule api-security --force
```

### 2. 手动添加规则文件

在 `~/.agent-rules/project-rules/` 目录下创建 `.mdc` 文件：

```markdown
---
title: "api-security"
description: "API安全检查规则"
category: "security"
weight: 9
conditions: "django,fastapi,flask,express,medium_project,large_project"
---

# API安全检查规则

## 描述
针对Web API项目的安全检查和最佳实践。

## 适用场景
- Django、FastAPI、Flask、Express等Web框架
- 中型到大型项目
- 面向外部用户的API服务

## 实施指南
1. 输入验证和清理
2. 身份验证和授权
3. HTTPS强制使用
4. 速率限制
5. 错误处理和日志记录

## 检查清单
- [ ] 所有输入都经过验证
- [ ] 实施了适当的身份验证
- [ ] 使用HTTPS传输
- [ ] 配置了速率限制
- [ ] 敏感信息不在日志中暴露
```

## 🧠 智能判断配置

### 配置文件位置
`~/.agent-rules/rule-config.json`

### 添加新规则到配置

```json
{
  "rules": {
    "api-security": {
      "category": "security",
      "description": "API安全检查规则",
      "conditions": {
        "frameworks": ["django", "fastapi", "flask", "express"],
        "project_size": ["medium", "large"],
        "has_api": true
      },
      "weight": 9,
      "tags": ["security", "api", "web"]
    }
  }
}
```

### 扩展检测条件

```json
{
  "conditions_mapping": {
    "frameworks": {
      "nextjs": ["next", "@next"],
      "nuxt": ["nuxt", "@nuxt"],
      "laravel": ["composer.json", "artisan"],
      "rails": ["Gemfile", "config/application.rb"]
    },
    "project_types": {
      "microservice": "多个小型服务目录",
      "monolith": "单一大型应用",
      "library": "可复用组件库"
    }
  }
}
```

## 🔧 自定义智能判断逻辑

### 1. 扩展项目分析函数

在 `grule.sh` 中的 `analyze_project()` 函数中添加新的检测逻辑：

```bash
# 检测微服务架构
if [[ -f "docker-compose.yml" ]] && [[ $(find . -name "Dockerfile" | wc -l) -gt 1 ]]; then
    analysis_result+=("architecture:microservice")
    echo "  🏗️ 微服务架构"
fi

# 检测API文档
if [[ -f "openapi.yml" ]] || [[ -f "swagger.yml" ]]; then
    analysis_result+=("has_api_docs:true")
    echo "  📚 API文档"
fi
```

### 2. 添加新的推荐逻辑

在 `recommend_rules_intelligently()` 函数中添加：

```bash
# 基于架构的规则
case "${project_attrs[architecture]}" in
    "microservice")
        recommended_rules+=("service-communication" "distributed-logging")
        reasoning+=("微服务架构需要服务间通信和分布式日志")
        ;;
esac

# 基于API文档
[[ "${project_attrs[has_api_docs]}" == "true" ]] && {
    recommended_rules+=("api-documentation-sync")
    reasoning+=("有API文档，需要保持文档同步")
}
```

## 📊 规则权重和优先级

### 权重系统
- **10**: 必需规则（implement-task, bug-fix）
- **8-9**: 高优先级（security, testing）
- **6-7**: 中优先级（quality, collaboration）
- **4-5**: 低优先级（documentation, optimization）

### 动态权重调整

```json
{
  "dynamic_weights": {
    "security_bonus": {
      "condition": "has_external_api",
      "bonus": 2
    },
    "team_bonus": {
      "condition": "team_size > 5",
      "bonus": 1
    }
  }
}
```

## 🎨 自定义规则类别

### 创建新类别

```json
{
  "categories": {
    "performance": {
      "description": "性能优化规则",
      "color": "orange",
      "priority": 7
    },
    "accessibility": {
      "description": "可访问性规则",
      "color": "purple",
      "priority": 6
    }
  }
}
```

## 🔍 高级检测示例

### 检测特定技术栈组合

```bash
# 检测JAMstack
if [[ -f "package.json" ]] && grep -q "gatsby\|next\|nuxt" package.json && [[ -d "static" || -d "public" ]]; then
    analysis_result+=("stack:jamstack")
    echo "  ⚡ JAMstack项目"
fi

# 检测全栈JavaScript
if [[ -f "package.json" ]] && grep -q "express\|koa" package.json && grep -q "react\|vue" package.json; then
    analysis_result+=("stack:fullstack_js")
    echo "  🌐 全栈JavaScript"
fi
```

### 检测项目复杂度

```bash
# 计算复杂度指标
local config_files=$(find . -name "*.config.*" -o -name ".*rc*" | wc -l)
local dependency_files=$(find . -name "package.json" -o -name "requirements.txt" -o -name "Cargo.toml" | wc -l)

if [[ $config_files -gt 10 ]] && [[ $dependency_files -gt 1 ]]; then
    analysis_result+=("complexity:high")
    echo "  🧩 高复杂度项目"
fi
```

## 📝 规则模板

### API安全规则模板

```markdown
---
title: "api-rate-limiting"
description: "API速率限制实施"
category: "security"
weight: 8
conditions: "web_backend,has_api,medium_project,large_project"
frameworks: ["django", "fastapi", "flask", "express"]
---

# API速率限制

## 目标
防止API滥用，提高服务稳定性。

## 实施步骤
1. 选择速率限制策略
2. 配置限制规则
3. 实施监控和告警
4. 测试和调优

## 技术实现
### Django
```python
# settings.py
RATELIMIT_ENABLE = True
RATELIMIT_USE_CACHE = 'default'
```

### FastAPI
```python
from slowapi import Limiter
limiter = Limiter(key_func=get_remote_address)
```

## 验证清单
- [ ] 配置了合理的速率限制
- [ ] 实施了监控和日志
- [ ] 测试了限制效果
- [ ] 文档化了限制策略
```

## 🚀 部署自定义规则

### 1. 本地开发
```bash
# 在项目根目录添加规则
mkdir -p custom-rules
echo "# 自定义规则" > custom-rules/my-rule.mdc

# 安装时包含自定义规则
grule --install --path ./custom-rules
```

### 2. 团队共享
```bash
# 创建团队规则仓库
git init team-rules
cd team-rules

# 添加规则配置
cp ~/.agent-rules/rule-config.json ./
# 修改配置添加团队特定规则

# 推送到团队仓库
git add . && git commit -m "Team rules"
git push origin main

# 团队成员使用
grule --deploy --path git@github.com:team/team-rules.git
```

## 💡 最佳实践

### 规则命名约定
- 使用kebab-case: `api-security`
- 包含类别前缀: `security-api-validation`
- 描述性名称: `django-database-optimization`

### 条件设置原则
- 具体明确：`django,postgresql,large_project`
- 避免过于宽泛：`python` ❌
- 组合使用：`web_backend,has_database,team_project` ✅

### 权重分配策略
- 安全相关：8-10
- 质量保证：6-8
- 生产力提升：5-7
- 文档维护：3-5

## 🔄 持续改进

### 规则效果追踪
```bash
# 查看规则使用统计
grule --rule-info api-security

# 分析推荐准确性
grule --analyze-effectiveness
```

### 社区贡献
1. 创建高质量规则
2. 提交到主仓库
3. 分享使用经验
4. 参与讨论和改进

---

通过这个扩展性框架，grule可以适应任何项目类型和团队需求，真正成为智能化的规则管理平台。 