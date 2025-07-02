#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
grule - 智能AI助手规则管理工具 (Python版本)

Description: 基于项目特征的智能规则推荐和管理系统
Author: AI Assistant
Version: 2.0.0
Url: https://github.com/epodak/agent-rules
"""

import argparse
import json
import logging
import os
import shlex
import subprocess
import shutil
import sys
import traceback
from contextlib import contextmanager
from dataclasses import dataclass
from functools import wraps
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.syntax import Syntax
    from rich.table import Table
    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False
    # 简单的替代实现
    class Console:
        def print(self, *args, **kwargs):
            print(*args)

console = Console()

@dataclass
class ProjectFeature:
    """项目特征数据类"""
    key: str
    value: str
    description: str
    confidence: float = 1.0

@dataclass
class RuleRecommendation:
    """规则推荐数据类"""
    name: str
    reason: str
    weight: int
    category: str
    confidence: float = 1.0

class GruleError(Exception):
    """Grule工具自定义异常"""
    pass

class PathManager:
    """路径管理器"""
    
    def __init__(self):
        self.original_cwd = Path.cwd()
        self.script_path = Path(sys.argv[0]).resolve()
        self.script_dir = self.script_path.parent
        self.agent_rules_dir = Path.home() / ".agent-rules"
    
    def normalize_path(self, path: Union[str, Path]) -> Path:
        """标准化路径"""
        p = Path(path)
        return p if p.is_absolute() else self.original_cwd / p
    
    def resolve_path(self, path: Union[str, Path]) -> Path:
        """将相对路径解析为绝对路径"""
        return self.normalize_path(path).resolve()

@contextmanager
def working_directory(path: Union[str, Path]):
    """工作目录上下文管理器"""
    prev_cwd = Path.cwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)

def error_handler(reraise=False):
    """错误处理装饰器"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                error_msg = f"""
错误类型: {type(e).__name__}
错误信息: {str(e)}
堆栈跟踪:
{traceback.format_exc()}
"""
                if RICH_AVAILABLE:
                    console.print(f"[red]执行错误[/red]")
                    console.print(Panel(error_msg, title="错误详情"))
                else:
                    print(f"执行错误: {error_msg}")
                
                logging.error(error_msg)
                if reraise:
                    raise
                return None
        return wrapper
    return decorator

def setup_logging(log_dir: Path = None):
    """配置日志系统"""
    if log_dir is None:
        log_dir = Path.cwd() / "logs"
    
    log_dir.mkdir(exist_ok=True)
    log_file = log_dir / "grule.log"
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )

class ProjectAnalyzer:
    """项目分析器"""
    
    def __init__(self, project_path: Path = None):
        self.project_path = project_path or Path.cwd()
        self.features: List[ProjectFeature] = []
    
    def analyze(self) -> List[ProjectFeature]:
        """执行项目分析"""
        self.features = []
        
        with working_directory(self.project_path):
            self._analyze_project_size()
            self._analyze_languages()
            self._analyze_frameworks()
            self._analyze_team_info()
            self._analyze_toolchain()
        
        return self.features
    
    def _analyze_project_size(self):
        """分析项目规模"""
        code_patterns = ["*.py", "*.js", "*.ts", "*.go", "*.rs", "*.swift", "*.java", "*.cs"]
        
        file_count = 0
        line_count = 0
        
        for pattern in code_patterns:
            files = list(self.project_path.rglob(pattern))
            file_count += len(files)
            
            for file_path in files:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        line_count += len(f.readlines())
                except:
                    continue
        
        if file_count > 50 or line_count > 10000:
            size = "large"
        elif file_count > 10 or line_count > 1000:
            size = "medium"
        else:
            size = "small"
        
        self.features.append(ProjectFeature(
            "project_size", size, 
            f"项目规模: {size} ({file_count}文件, ~{line_count}行代码)"
        ))
    
    def _analyze_languages(self):
        """分析编程语言"""
        language_indicators = {
            "javascript": ["package.json", "*.js", "*.jsx"],
            "typescript": ["tsconfig.json", "*.ts", "*.tsx"],
            "python": ["requirements.txt", "pyproject.toml", "setup.py", "*.py"],
            "rust": ["Cargo.toml", "*.rs"],
            "go": ["go.mod", "*.go"],
            "swift": ["Package.swift", "*.swift"],
            "java": ["pom.xml", "build.gradle", "*.java"],
            "csharp": ["*.csproj", "*.sln", "*.cs"]
        }
        
        for lang, indicators in language_indicators.items():
            found = False
            for indicator in indicators:
                if indicator.startswith("*."):
                    if list(self.project_path.rglob(indicator)):
                        found = True
                        break
                else:
                    if (self.project_path / indicator).exists():
                        found = True
                        break
            
            if found:
                self.features.append(ProjectFeature(
                    "languages", lang, f"检测到语言: {lang}"
                ))
    
    def _analyze_frameworks(self):
        """分析框架"""
        if (self.project_path / "package.json").exists():
            try:
                with open(self.project_path / "package.json", 'r', encoding='utf-8') as f:
                    package_data = json.load(f)
                    
                dependencies = {**package_data.get("dependencies", {}), 
                              **package_data.get("devDependencies", {})}
                
                framework_map = {
                    "react": ["react", "next"],
                    "vue": ["vue", "@vue"],
                    "express": ["express"],
                    "angular": ["@angular"]
                }
                
                for framework, packages in framework_map.items():
                    if any(pkg in dependencies for pkg in packages):
                        self.features.append(ProjectFeature(
                            "frameworks", framework, f"检测到框架: {framework}"
                        ))
            except:
                pass
        
        # Python框架检测
        python_files = ["requirements.txt", "pyproject.toml"]
        for file_name in python_files:
            file_path = self.project_path / file_name
            if file_path.exists():
                try:
                    content = file_path.read_text(encoding='utf-8')
                    framework_map = {
                        "django": ["django"],
                        "fastapi": ["fastapi"],
                        "flask": ["flask"]
                    }
                    
                    for framework, indicators in framework_map.items():
                        if any(indicator in content.lower() for indicator in indicators):
                            self.features.append(ProjectFeature(
                                "frameworks", framework, f"检测到框架: {framework}"
                            ))
                except:
                    pass
    
    def _analyze_team_info(self):
        """分析团队信息"""
        git_dir = self.project_path / ".git"
        if git_dir.exists():
            self.features.append(ProjectFeature(
                "has_git", "true", "Git项目"
            ))
            
            try:
                # 获取贡献者数量
                result = subprocess.run(
                    ["git", "log", "--format=%ae"],
                    capture_output=True, text=True, cwd=self.project_path
                )
                if result.returncode == 0:
                    contributors = len(set(result.stdout.strip().split('\n')))
                    
                    if contributors > 10:
                        team_size = "large"
                    elif contributors > 3:
                        team_size = "medium"
                    elif contributors > 1:
                        team_size = "small"
                    else:
                        team_size = "solo"
                    
                    self.features.append(ProjectFeature(
                        "team_size", team_size, f"团队规模: {team_size} ({contributors}贡献者)"
                    ))
                
                # 获取提交数量
                result = subprocess.run(
                    ["git", "rev-list", "--count", "HEAD"],
                    capture_output=True, text=True, cwd=self.project_path
                )
                if result.returncode == 0:
                    commits = int(result.stdout.strip())
                    
                    if commits > 100:
                        maturity = "mature"
                    elif commits > 10:
                        maturity = "developing"
                    else:
                        maturity = "new"
                    
                    self.features.append(ProjectFeature(
                        "project_maturity", maturity, f"项目成熟度: {maturity} ({commits}提交)"
                    ))
            except:
                pass
    
    def _analyze_toolchain(self):
        """分析工具链"""
        # 测试框架检测
        test_indicators = [
            "test", "tests", "spec", "__tests__", 
            "*.test.*", "*.spec.*"
        ]
        
        has_testing = False
        for indicator in test_indicators:
            if indicator.startswith("*."):
                if list(self.project_path.rglob(indicator)):
                    has_testing = True
                    break
            else:
                if (self.project_path / indicator).exists():
                    has_testing = True
                    break
        
        if has_testing:
            self.features.append(ProjectFeature(
                "has_testing", "true", "包含测试"
            ))
        
        # CI/CD检测
        ci_indicators = [".github/workflows", ".gitlab-ci.yml", "Jenkinsfile"]
        for indicator in ci_indicators:
            if (self.project_path / indicator).exists():
                self.features.append(ProjectFeature(
                    "has_cicd", "true", "配置CI/CD"
                ))
                break
        
        # 容器化检测
        if (self.project_path / "Dockerfile").exists():
            self.features.append(ProjectFeature(
                "has_docker", "true", "容器化项目"
            ))
        
        # 文档检测
        readme_path = self.project_path / "README.md"
        if readme_path.exists():
            try:
                content = readme_path.read_text(encoding='utf-8')
                if len(content.split('\n')) > 20:
                    self.features.append(ProjectFeature(
                        "has_documentation", "true", "文档完善"
                    ))
            except:
                pass

class RuleEngine:
    """规则推荐引擎"""
    
    def __init__(self, config_path: Path = None):
        self.path_manager = PathManager()
        self.config_path = config_path or (self.path_manager.agent_rules_dir / "rule-config.json")
        self.config = self._load_config()
    
    def _load_config(self) -> Dict:
        """加载配置文件"""
        if not self.config_path.exists():
            return self._get_default_config()
        
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logging.warning(f"加载配置文件失败: {e}，使用默认配置")
            return self._get_default_config()
    
    def _get_default_config(self) -> Dict:
        """获取默认配置"""
        return {
            "rules": {
                "implement-task": {
                    "category": "core",
                    "description": "任务实现规则",
                    "conditions": {"always": True},
                    "weight": 10,
                    "tags": ["essential", "development"]
                },
                "bug-fix": {
                    "category": "core",
                    "description": "Bug修复规则", 
                    "conditions": {"always": True},
                    "weight": 10,
                    "tags": ["essential", "debugging"]
                },
                "quick-wins": {
                    "category": "productivity",
                    "description": "快速胜利策略",
                    "conditions": {"always": True},
                    "weight": 8,
                    "tags": ["productivity", "optimization"]
                }
            }
        }
    
    def recommend_rules(self, features: List[ProjectFeature]) -> List[RuleRecommendation]:
        """基于项目特征推荐规则"""
        recommendations = []
        feature_dict = {f.key: f.value for f in features}
        
        # 核心规则（总是推荐）
        core_rules = [
            RuleRecommendation("implement-task", "核心开发流程规则", 10, "core"),
            RuleRecommendation("bug-fix", "核心开发流程规则", 10, "core"),
            RuleRecommendation("quick-wins", "快速胜利策略", 8, "productivity")
        ]
        recommendations.extend(core_rules)
        
        # 基于项目规模的推荐
        project_size = feature_dict.get("project_size", "small")
        if project_size == "large":
            recommendations.extend([
                RuleRecommendation("code-analysis", "大型项目需要严格的代码质量控制", 9, "quality"),
                RuleRecommendation("pr-review", "大型项目需要代码审查", 8, "collaboration"),
                RuleRecommendation("continuous-improvement", "大型项目需要持续改进", 7, "process")
            ])
        elif project_size == "medium":
            recommendations.extend([
                RuleRecommendation("code-analysis", "中型项目需要代码质量检查", 7, "quality"),
                RuleRecommendation("check", "中型项目需要检查机制", 6, "quality")
            ])
        else:  # small
            recommendations.extend([
                RuleRecommendation("clean", "小型项目重点关注代码整洁", 7, "maintenance"),
                RuleRecommendation("commit", "小型项目需要提交规范", 6, "workflow")
            ])
        
        # 基于语言的推荐
        languages = [f.value for f in features if f.key == "languages"]
        for lang in languages:
            if lang == "swift":
                recommendations.append(
                    RuleRecommendation("modern-swift", "Swift项目需要现代Swift开发规范", 9, "language_specific")
                )
            elif lang in ["javascript", "typescript", "python", "java", "csharp"]:
                recommendations.append(
                    RuleRecommendation("code-analysis", f"{lang}项目需要代码质量分析", 7, "quality")
                )
        
        # 基于团队规模的推荐
        team_size = feature_dict.get("team_size", "solo")
        if team_size in ["medium", "large"]:
            recommendations.extend([
                RuleRecommendation("pr-review", "团队项目需要代码审查", 8, "collaboration"),
                RuleRecommendation("add-to-changelog", "团队项目需要变更记录", 6, "documentation")
            ])
        
        # 基于工具链的推荐
        if feature_dict.get("has_testing") == "true":
            recommendations.append(
                RuleRecommendation("five", "已有测试框架，增强测试质量", 8, "testing")
            )
        
        if feature_dict.get("has_git") == "true":
            recommendations.append(
                RuleRecommendation("commit", "Git项目需要提交规范", 8, "workflow")
            )
        
        # 添加效果追踪
        recommendations.append(
            RuleRecommendation("rule-effectiveness-tracker", "跟踪规则使用效果", 5, "meta")
        )
        
        # 去重并排序
        unique_recommendations = {}
        for rec in recommendations:
            if rec.name not in unique_recommendations or rec.weight > unique_recommendations[rec.name].weight:
                unique_recommendations[rec.name] = rec
        
        return sorted(unique_recommendations.values(), key=lambda x: x.weight, reverse=True)

class RuleManager:
    """规则管理器"""
    
    def __init__(self):
        self.path_manager = PathManager()
        self.analyzer = ProjectAnalyzer()
        self.engine = RuleEngine()
    
    @error_handler(reraise=False)
    def deploy_rules(self, source_path: str = None, force: bool = False) -> bool:
        """部署规则库"""
        agent_rules_dir = self.path_manager.agent_rules_dir
        
        if agent_rules_dir.exists() and not force:
            console.print("[yellow]规则库已存在，使用 --force 强制重新部署[/yellow]")
            return False
        
        if force and agent_rules_dir.exists():
            shutil.rmtree(agent_rules_dir)
        
        if source_path:
            # 从本地路径部署
            source = Path(source_path)
            if not source.exists():
                console.print(f"[red]源路径不存在: {source_path}[/red]")
                return False
            
            shutil.copytree(source, agent_rules_dir)
            console.print(f"[green]从本地路径部署成功: {source_path}[/green]")
        else:
            # 从Git仓库部署
            repo_url = "https://github.com/epodak/agent-rules.git"
            try:
                result = subprocess.run(
                    ["git", "clone", repo_url, str(agent_rules_dir)],
                    capture_output=True, text=True
                )
                if result.returncode == 0:
                    console.print("[green]Git仓库克隆成功[/green]")
                else:
                    console.print(f"[red]Git克隆失败: {result.stderr}[/red]")
                    return False
            except FileNotFoundError:
                console.print("[red]Git命令不可用，请手动下载规则库[/red]")
                return False
        
        # 创建配置文件
        self._create_config_file()
        console.print("[green]规则库部署完成[/green]")
        return True
    
    def _create_config_file(self):
        """创建配置文件"""
        config_path = self.path_manager.agent_rules_dir / "rule-config.json"
        if not config_path.exists():
            default_config = self.engine._get_default_config()
            with open(config_path, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, ensure_ascii=False, indent=2)
    
    @error_handler(reraise=False)
    def install_rules(self, target: str = "both") -> bool:
        """在当前项目中安装规则"""
        if not self.path_manager.agent_rules_dir.exists():
            console.print("[red]规则库未部署，请先运行 deploy[/red]")
            return False
        
        # [步骤A] 安装核心联动规则 (新功能)
        self._install_foundational_rules()

        # [步骤B] 执行项目分析并安装推荐规则 (保留原有逻辑)
        features = self.analyzer.analyze()
        self._display_analysis_results(features)
        
        recommendations = self.engine.recommend_rules(features)
        self._display_recommendations(recommendations)
        
        recommended_rule_names = [r.name for r in recommendations]

        if target in ["cursor", "both"]:
            # 原有的方法现在只负责安装推荐的规则
            self._install_cursor_rules(recommended_rule_names)
        
        if target in ["claude", "both"]:
            # claude 的规则可以合并基础和推荐的
            all_rule_names = ["gissue-workflow", "gmemory-best-practices", "project-retrospective"] + recommended_rule_names
            # 去重
            unique_rule_names = list(dict.fromkeys(all_rule_names))
            self._install_claude_rules(unique_rule_names)
        
        console.print("\n[bold green]✅ 规则安装完成！[/bold green]")
        return True
    
    def _install_foundational_rules(self):
        """
        安装核心的、与项目无关的联动规则。
        这些规则教会 AI 如何使用 gissue 和 gmemory。
        """
        console.print("\n[cyan]正在安装核心联动规则...[/cyan]")

        core_rules_to_install = [
            "gissue-workflow.mdc",
            "gmemory-best-practices.mdc",
            "project-retrospective.mdc"
        ]
        
        # 源目录：~/.agent-rules/global-rules/
        source_dir = self.path_manager.agent_rules_dir / "global-rules"
        # 目标目录：当前项目下的 .cursor/rules/
        dest_dir = self.path_manager.original_cwd / ".cursor/rules"
        
        if not source_dir.exists():
            console.print(f"[yellow]警告: 核心规则目录 '{source_dir}' 未找到。跳过此步骤。[/yellow]")
            return

        try:
            # 确保目标目录存在
            dest_dir.mkdir(parents=True, exist_ok=True)
            
            # 拷贝文件
            installed_count = 0
            for rule_filename in core_rules_to_install:
                source_file = source_dir / rule_filename
                if source_file.exists():
                    dest_file = dest_dir / source_file.name
                    shutil.copy2(source_file, dest_file)
                    console.print(f"  - [green]已安装:[/green] {source_file.name}")
                    installed_count += 1
                else:
                    console.print(f"  - [yellow]未找到规则:[/yellow] {rule_filename}")

            if installed_count == 0:
                 console.print(f"[yellow]在 '{source_dir}' 中未找到任何指定的核心规则文件。[/yellow]")
            else:
                console.print(f"[green]核心联动规则安装完成: {installed_count}个[/green]")

        except Exception as e:
            console.print(f"[red]安装核心规则时发生错误: {e}[/red]")
            logging.error(f"Failed to install foundational rules: {e}", exc_info=True)
    
    def _display_analysis_results(self, features: List[ProjectFeature]):
        """显示分析结果"""
        if RICH_AVAILABLE:
            table = Table(title="项目分析结果")
            table.add_column("特征类型", style="cyan")
            table.add_column("检测结果", style="magenta")
            table.add_column("描述", style="green")
            
            for feature in features:
                table.add_row(feature.key, feature.value, feature.description)
            
            console.print(table)
        else:
            print("\n项目分析结果:")
            for feature in features:
                print(f"  {feature.key}: {feature.value} - {feature.description}")
    
    def _display_recommendations(self, recommendations: List[RuleRecommendation]):
        """显示推荐结果"""
        if RICH_AVAILABLE:
            table = Table(title="智能推荐规则")
            table.add_column("规则名称", style="cyan")
            table.add_column("类别", style="yellow")
            table.add_column("权重", style="red")
            table.add_column("推荐理由", style="green")
            
            for rec in recommendations:
                table.add_row(rec.name, rec.category, str(rec.weight), rec.reason)
            
            console.print(table)
        else:
            print("\n智能推荐规则:")
            for rec in recommendations:
                print(f"  {rec.name} ({rec.category}, 权重:{rec.weight}) - {rec.reason}")
    
    def _install_cursor_rules(self, rule_names: List[str]):
        """安装Cursor规则"""
        cursor_dir = Path(".cursor/rules")
        cursor_dir.mkdir(parents=True, exist_ok=True)
        
        rules_dir = self.path_manager.agent_rules_dir / "project-rules"
        installed_count = 0
        
        for rule_name in rule_names:
            rule_file = rules_dir / f"{rule_name}.mdc"
            if rule_file.exists():
                target_file = cursor_dir / f"{rule_name}.mdc"
                shutil.copy2(rule_file, target_file)
                installed_count += 1
        
        console.print(f"[green]Cursor规则安装完成: {installed_count}个[/green]")
    
    def _install_claude_rules(self, rule_names: List[str]):
        """安装Claude规则"""
        claude_file = Path("CLAUDE.md")
        rules_dir = self.path_manager.agent_rules_dir / "project-rules"
        
        content = ["# Claude Code Rules\n", "AI助手规则 - 由grule工具自动生成\n\n"]
        
        for rule_name in rule_names:
            rule_file = rules_dir / f"{rule_name}.mdc"
            if rule_file.exists():
                try:
                    rule_content = rule_file.read_text(encoding='utf-8')
                    # 移除前置的YAML头部
                    lines = rule_content.split('\n')
                    start_idx = 0
                    if lines[0].strip() == '---':
                        for i, line in enumerate(lines[1:], 1):
                            if line.strip() == '---':
                                start_idx = i + 1
                                break
                    
                    content.append(f"## {rule_name}\n")
                    content.append('\n'.join(lines[start_idx:]))
                    content.append('\n\n')
                except Exception as e:
                    logging.warning(f"读取规则文件失败 {rule_name}: {e}")
        
        claude_file.write_text(''.join(content), encoding='utf-8')
        console.print(f"[green]Claude规则安装完成: {claude_file}[/green]")

def create_parser() -> argparse.ArgumentParser:
    """创建参数解析器"""
    parser = argparse.ArgumentParser(
        description='grule - 智能AI助手规则管理工具',
        add_help=False,
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument('-h', '--help', action='store_true', help='显示帮助信息')
    parser.add_argument('-d', '--deploy', action='store_true', help='部署规则库到本地系统')
    parser.add_argument('-i', '--install', action='store_true', help='在当前项目中安装规则')
    parser.add_argument('-u', '--update', action='store_true', help='更新本地规则库')
    parser.add_argument('-s', '--status', action='store_true', help='显示规则库状态')
    parser.add_argument('--add-rule', metavar='NAME', help='创建新的自定义规则')
    parser.add_argument('--list-rules', action='store_true', help='列出所有可用规则')
    parser.add_argument('--rule-info', metavar='NAME', help='显示规则详细信息')
    parser.add_argument('-p', '--path', metavar='PATH', help='指定自定义规则库路径')
    parser.add_argument('-t', '--target', choices=['cursor', 'claude', 'both'], 
                       default='both', help='指定安装目标')
    parser.add_argument('-f', '--force', action='store_true', help='强制执行操作')
    parser.add_argument('-l', '--log', action='store_true', help='启用详细日志')
    
    return parser

def get_help_text() -> str:
    """返回帮助信息"""
    return """
grule - 智能AI助手规则管理工具 (Python版本)

用法: python grule.py [选项]

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
    python grule.py                      # 智能模式：自动分析并安装规则
    python grule.py --deploy             # 首次部署规则库
    python grule.py --install            # 在项目中安装推荐规则
    python grule.py --list-rules         # 查看所有可用规则
    python grule.py --add-rule api-security  # 创建API安全规则

智能特性:
    • 🔍 深度项目分析：检测语言、框架、团队规模、项目成熟度
    • 🧠 智能规则推荐：基于项目特征匹配最相关的规则
    • 📊 效果追踪：量化规则使用效果和ROI
    • 🔧 可扩展性：支持自定义规则和条件配置
    • 👥 团队协作：支持个人和团队开发模式
"""

def show_help():
    """显示帮助信息"""
    help_text = get_help_text()
    if RICH_AVAILABLE:
        syntax = Syntax(help_text, "markdown", theme="monokai")
        console.print(Panel(syntax, title="使用帮助", title_align="left"))
    else:
        print(help_text)

def main():
    """主函数"""
    try:
        # 初始化日志
        setup_logging()
        
        # 解析参数
        parser = create_parser()
        args = parser.parse_args()
        
        # 处理帮助请求
        if args.help:
            show_help()
            return
        
        # 创建规则管理器
        rule_manager = RuleManager()
        
        # 执行相应操作
        if args.deploy:
            rule_manager.deploy_rules(args.path, args.force)
        elif args.install:
            rule_manager.install_rules(args.target)
        elif args.status:
            # TODO: 实现状态检查
            console.print("状态检查功能待实现")
        elif args.update:
            # TODO: 实现更新功能
            console.print("更新功能待实现")
        elif args.list_rules:
            # TODO: 实现规则列表
            console.print("规则列表功能待实现")
        elif args.add_rule:
            # TODO: 实现添加规则
            console.print(f"添加规则功能待实现: {args.add_rule}")
        elif args.rule_info:
            # TODO: 实现规则信息
            console.print(f"规则信息功能待实现: {args.rule_info}")
        else:
            # 默认智能模式
            if not rule_manager.path_manager.agent_rules_dir.exists():
                console.print("[yellow]规则库未部署，执行首次部署...[/yellow]")
                if rule_manager.deploy_rules():
                    rule_manager.install_rules(args.target)
            else:
                rule_manager.install_rules(args.target)
    
    except KeyboardInterrupt:
        console.print("\n[yellow]操作被用户取消[/yellow]")
    except Exception as e:
        console.print(f"[red]程序执行出错: {e}[/red]")
        logging.error(f"程序执行出错: {e}", exc_info=True)
    finally:
        logging.shutdown()

if __name__ == "__main__":
    main() 