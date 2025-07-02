# G-MEMORY: agent-rules (智能规则管理工具)

---
*This memo is for my future self. It's a private record of the 'why' and 'how' behind this project, designed to fight the forgetting curve.*
---

## 🎯 1. The "Why": Core Goal & Problem Statement
<!-- 我当初为什么要做这个？解决了什么具体问题？最初的灵感或痛点是什么？ -->
核心目标是创建一个智能工具 (`grule.py`)，用于自动化管理和部署AI助手的"规则"。

主要解决的问题是：为不同类型的软件项目（如大型后端服务、小型SwiftUI应用）手动维护和切换不同的AI指令集（rules）非常繁琐且容易出错。此工具通过自动分析项目特征（语言、框架、规模等），为其推荐并安装最合适的规则集。

同时，它确保了一组核心的、与项目无关的"联动规则"被安装到每个项目中，教会AI如何使用本体系下的其他工具（如 `gissue`, `gmemory`），保证了基础工具链的可用性。

## 🏗️ 2. The "How": Architecture & Workflow
<!-- 它是如何运作的？画一个简单的流程图或描述核心组件的交互。输入是什么，输出是什么？ -->
该系统围绕一个中央规则库和本地项目部署的逻辑运作。

**核心组件:**
- **`grule.py`**: 用户侧的主命令脚本，负责所有逻辑。
- **`~/.agent-rules/`**: 中央规则库。通过 `grule.py --deploy` 命令从远程Git仓库克隆而来，是所有规则的"唯一真实来源"。
- **`global-rules/`**: 位于中央库中，存放与项目无关的核心规则（如`gissue-workflow.mdc`）。
- **`project-rules/`**: 位于中央库中，存放与具体技术栈或项目类型相关的推荐规则（如`modern-swift.mdc`）。
- **`./.cursor/rules/`**: 在用户目标项目中创建的目录，用于存放最终安装的规则文件。

**工作流程:**
1.  **部署 (`grule.py --deploy`)**: 用户首次使用时，从指定的Git仓库克隆所有规则到本地的 `~/.agent-rules` 目录。
2.  **安装 (`grule.py -i` 或 `grule.py`)**:
    a. **安装核心规则**: 首先，从 `~/.agent-rules/global-rules/` 目录中，拷贝一份预先定义好的核心规则列表（`gissue-workflow.mdc`等）到当前项目的 `.cursor/rules/` 目录下。
    b. **分析项目**: 脚本扫描当前项目，检测语言、框架、Git历史、文件数量等特征。
    c. **推荐并安装规则**: 基于分析结果，从 `~/.agent-rules/project-rules/` 目录中选择最匹配的规则，并同样拷贝到项目的 `.cursor/rules/` 目录下。

## 🤔 3. The "Why This Way": Key Decisions & Rationale
<!-- 
我为什么选择A方案而不是B方案？
- **技术选型:** e.g., "Why Poetry over pip-tools? Because..."
- **算法/逻辑:** e.g., "Why recursive instead of iterative? Because..."
- **架构决策:** e.g., "Why a monolithic script instead of microservices? Because..."
记录下当时考虑过的其他选项和放弃它们的原因。
-->
- **决策: 分离规则库与执行脚本，采用中央`~/.agent-rules`目录。**
  - **理由:** 这是最核心的架构决策。它将规则内容与脚本逻辑解耦。这样做的好处是，未来更新规则（增、删、改）只需要更新Git仓库，用户执行 `grule.py --update` (待实现) 即可同步，无需修改或重新分发 `grule.py` 脚本本身，极大地提高了灵活性和可维护性。

- **决策: 将核心规则的安装源从"脚本所在目录"改为"中央规则库"。**
  - **理由:** 最初的实现是从 `grule.py` 脚本旁边的 `global-rules` 目录查找核心规则，这导致当脚本被放到全局路径（如`/usr/local/bin`）下时，会因找不到该目录而失败。将其统一指向 `~/.agent-rules/global-rules`，确保了无论脚本在何处运行，都能找到正确的规则源，实现了真正的"全局运行"。

- **决策: 硬编码需要安装的核心规则列表，而不是遍历`global-rules`目录。**
  - **理由:** 最初的实现是安装 `global-rules` 目录下的所有规则，这太隐式了。如果未来向目录中添加了新的、可能用于测试或非通用的规则，它会被自动安装到所有项目中，引发意料之外的行为。明确地在代码中定义一个列表，可以确保安装行为是稳定和可预测的。

## 🚧 4. The "Gotchas": Implementation Details & Pitfalls
<!-- 
具体是怎么做的，以及哪些地方需要特别注意？
- **关键代码片段:** 贴出最核心或最难理解的代码。
- **踩过的坑:** e.g., "API X has a hidden rate limit of Y", "This library has a bug in version Z".
- **魔法数字/硬编码值的解释:** e.g., "Timeout is set to 3.7 seconds because..."
- **环境配置要点:** e.g., "Requires specific env var `FOO_BAR` to be set".
-->
- **踩过的坑 1: 脚本的全局可执行性问题。**
  - **描述:** `_install_foundational_rules` 方法最初使用 `self.path_manager.script_dir` 来定位 `global-rules`，这在脚本被移动到全局PATH路径下时会失效。
  - **解决方案:** 将其路径修改为 `self.path_manager.agent_rules_dir`，确保始终从 `~/.agent-rules` 这个稳定的位置读取。

- **踩过的坑 2: 核心规则安装的精确性。**
  - **描述:** 最初实现是拷贝 `global-rules` 目录下的所有 `.mdc` 文件，这与"只安装指定的3个核心规则"的需求不符。
  - **解决方案:** 重构为使用一个预定义的Python列表来精确控制要安装的文件，如代码所示：
    ```python
    core_rules_to_install = [
        "gissue-workflow.mdc",
        "gmemory-best-practices.mdc",
        "project-retrospective.mdc"
    ]
    # ... then iterate over this list to copy files
    ```

- **环境依赖:** `deploy` 功能依赖系统环境中已安装 `git` 命令并将其加入了`PATH`。

## 🚀 5. The "What's Next": Future Ideas & Unfinished Business
<!-- 
未来可能的改进方向或未完成的想法。
- **Refactoring:** "This part is messy and could be refactored by..."
- **New Features:** "It would be cool to add..."
- **Open Questions:** "I'm still not sure about the best way to handle..."
-->
- **实现TODO功能:** 脚本中有大量占位符功能（如 `--update`, `--status`, `--list-rules`）亟待实现。特别是 `--update`，它应该执行 `git pull` 来更新 `~/.agent-rules` 目录。
- **配置化推荐引擎:** `RuleEngine` 中的推荐逻辑目前是硬编码在Python代码里的。可以将其迁移到 `rule-config.json` 文件中，使得推荐逻辑本身也可以通过更新配置文件来调整，而无需修改代码。
- **支持用户自定义规则:** `--add-rule` 功能需要设计。用户创建的规则应该存放在哪里？是 `~/.agent-rules` 还是一个独立的 `~/.config/grule/custom-rules` 目录？这是一个待决问题。
