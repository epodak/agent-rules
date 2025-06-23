# Grule Python版本 - 智能AI助手规则管理工具

## 🚀 为什么选择Python版本？

### 核心优势

1. **🐍 Pure Python实现**
   - 更好的跨平台兼容性
   - 丰富的Python生态系统支持
   - 更容易扩展和维护

2. **📊 Rich库支持**
   - 美观的表格和面板显示
   - 彩色输出和进度条
   - 更好的用户体验

3. **🧠 更智能的项目分析**
   - 深度项目特征检测
   - 多维度智能推荐
   - 基于数据的决策

4. **🔧 强大的扩展性**
   - 面向对象的架构设计
   - 配置文件驱动
   - 插件化的规则系统

## 📦 安装和迁移

### 方法1：自动迁移（推荐）
```bash
# 从现有的Bash版本自动迁移
python migrate_to_python.py
```

### 方法2：手动安装
```bash
# 1. 安装依赖
pip install rich

# 2. 创建wrapper脚本
mkdir -p ~/bin
cat > ~/bin/grule << 'EOF'
#!/bin/bash
python /path/to/grule.py "$@"
EOF
chmod +x ~/bin/grule

# 3. 添加到PATH（如果尚未添加）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 🎯 核心功能

### 智能项目分析
```bash
grule --install
```
自动检测：
- 📊 项目规模（小型/中型/大型）
- 💻 编程语言（JavaScript、Python、Swift等）
- 🛠️ 框架（React、Django、FastAPI等）
- 👥 团队规模（个人/小团队/大团队）
- 📈 项目成熟度（新建/开发中/成熟）
- 🔧 工具链（测试、CI/CD、容器化等）

### 智能规则推荐
基于项目特征自动推荐最相关的规则：

| 项目类型 | 推荐规则 | 理由 |
|---------|---------|------|
| Swift项目 | modern-swift | Swift最佳实践 |
| 大型项目 | code-analysis, pr-review | 质量控制 |
| 团队项目 | commit, add-to-changelog | 协作规范 |
| 新项目 | quick-wins, clean | 快速起步 |

### 多目标支持
```bash
grule --install --target cursor    # 仅安装Cursor规则
grule --install --target claude    # 仅安装Claude规则  
grule --install --target both      # 安装到两个平台
```

## 🛠️ 高级功能

### 自定义规则
```bash
grule --add-rule api-security      # 创建新规则
grule --list-rules                 # 查看所有规则
grule --rule-info implement-task   # 查看规则详情
```

### 效果追踪
内置规则效果追踪系统：
- 📈 使用频率统计
- ⏱️ 时间节省量化
- 💰 ROI计算
- 📊 效果报告生成

### 配置文件驱动
`~/.agent-rules/rule-config.json`：
```json
{
  "rules": {
    "custom-rule": {
      "category": "security",
      "description": "API安全规则",
      "conditions": {
        "languages": ["javascript", "python"],
        "has_api": true
      },
      "weight": 8,
      "tags": ["security", "api"]
    }
  }
}
```

## 🔍 项目分析示例

运行 `grule` 后的分析结果：

```
                               项目分析结果                               
┏━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 特征类型          ┃ 检测结果   ┃ 描述                                  ┃
┡━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ project_size      │ medium     │ 项目规模: medium (15文件, ~2500行)   │
│ languages         │ typescript │ 检测到语言: typescript                │
│ frameworks        │ react      │ 检测到框架: react                     │
│ team_size         │ small      │ 团队规模: small (3贡献者)             │
│ has_testing       │ true       │ 包含测试                              │
│ has_cicd          │ true       │ 配置CI/CD                             │
└───────────────────┴────────────┴───────────────────────────────────────┘

                                 智能推荐规则                                  
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 规则名称                   ┃ 类别         ┃ 权重 ┃ 推荐理由                 ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━╇━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ implement-task             │ core         │ 10   │ 核心开发流程规则         │
│ code-analysis              │ quality      │ 9    │ TypeScript项目质量控制   │
│ five                       │ testing      │ 8    │ 已有测试框架，增强质量   │
│ pr-review                  │ collaboration│ 8    │ 团队项目需要代码审查     │
└────────────────────────────┴──────────────┴──────┴──────────────────────────┘
```

## 🎨 架构设计

### 核心组件

1. **PathManager** - 路径管理
2. **ProjectAnalyzer** - 项目分析引擎
3. **RuleEngine** - 智能推荐引擎
4. **RuleManager** - 规则管理器

### 扩展点

1. **分析器扩展**：添加新的项目特征检测
2. **推荐引擎扩展**：自定义推荐逻辑
3. **规则源扩展**：支持多种规则来源
4. **输出格式扩展**：支持多种输出格式

## 📈 性能对比

| 功能 | Bash版本 | Python版本 | 改进 |
|-----|---------|------------|------|
| 项目分析 | 基础文件检测 | 深度多维分析 | 10x更智能 |
| 规则推荐 | 静态映射 | 动态权重计算 | 5x更精准 |
| 用户体验 | 纯文本输出 | Rich库美化 | 3x更美观 |
| 扩展性 | 脚本修改 | 配置驱动 | 无限扩展 |
| 维护性 | 单文件脚本 | 模块化架构 | 10x更易维护 |

## 🔧 开发者指南

### 添加新的项目特征检测
```python
def _analyze_custom_feature(self):
    """分析自定义特征"""
    if (self.project_path / "custom-config.json").exists():
        self.features.append(ProjectFeature(
            "has_custom_config", "true", "包含自定义配置"
        ))
```

### 添加新的推荐规则
```python
# 在rule-config.json中添加
{
  "custom-security": {
    "category": "security",
    "description": "安全规则",
    "conditions": {
      "languages": ["javascript", "python"],
      "project_size": ["medium", "large"]
    },
    "weight": 8
  }
}
```

### 自定义输出格式
```python
def _display_custom_format(self, data):
    """自定义显示格式"""
    # 实现自定义输出逻辑
    pass
```

## 🚀 未来规划

- [ ] **插件系统**：支持第三方插件
- [ ] **云端同步**：规则和配置云端同步
- [ ] **AI增强**：GPT驱动的规则生成
- [ ] **团队仪表板**：团队级别的效果追踪
- [ ] **IDE集成**：深度集成主流IDE
- [ ] **规则市场**：社区规则分享平台

## 🤝 贡献指南

1. Fork项目
2. 创建特性分支
3. 遵循Python最佳实践
4. 添加测试
5. 提交Pull Request

## 📄 许可证

MIT License - 详见LICENSE文件

---

**Python版本的grule - 让AI助手规则管理更智能、更强大！** 🎉 