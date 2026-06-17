# Harness-Lite

> **小团队的AI协作工程化框架** · 让2-5人小团队也能享受工程化红利

[![Version](https://img.shields.io/badge/version-1.0.20-blue)]() [![License](https://img.shields.io/badge/license-MIT-green)]() [![Status](https://img.shields.io/badge/status-open--source-brightgreen)]()

---

## ⚡ 30秒理解

```
你的团队遇到的问题：             Harness-Lite解决的方式：
─────────────────────────       ─────────────────────────
AI产出"看人下菜"   ────►        统一的协作约定 + 技术栈规则
踩过的坑反复踩     ────►        知识库蒸馏 + 经验沉淀
小需求也要写PRD？   ────►        路径分级（小需求轻量流程）
单测过了就上线？   ────►        验收分层（强烈推荐E2E）
AI偷偷做了越界事    ────►        多Agent上下文隔离
git push怕推错     ────►        hook门禁防护
```

**5分钟安装，30分钟跑通第一个需求。**

---

## 🎯 这是什么

**Harness-Lite** 是一套基于《AI编程时代的软件工程》方法论提炼的轻量化工程框架，专为**2-5人小团队**设计。

它给你的项目带来：

1. **AI产出质量稳定** — CLAUDE.md自动加载技术栈约束，AI不再"自由发挥"
2. **协作有共识** — 团队约定入版本库，新人加入即上手
3. **小需求不浪费时间** — 路径分级，CRUD/改文案走轻量流程
4. **质量可追溯** — 4阶段产物链路 + 反向校验
5. **知识不流失** — 踩过的坑结构化沉淀
6. **危险有门禁** — git push、敏感文件、危险命令多重防护

---

## 🚀 快速开始（5分钟）

```bash
# 在你的项目根目录运行
$ cd your-project
$ /path/to/harness-lite/scripts/init.sh

# 跟随向导：
> 选择档位（Lite/Standard/Pro）
> 确认技术栈
> 启用模块

# 完成后，开新会话验证
$ claude
> /clear
> 介绍一下我们项目
```

详见：[5 分钟快速上手](docs/01-getting-started/01-quickstart.md)

---

## 🏗️ 核心架构

```
你的项目（已安装Harness-Lite后）
├── CLAUDE.md                  # AI每次会话自动加载
├── .claude/
│   ├── rules/                  # 行为准则 + 技术栈约束
│   ├── skills/                 # 主skill（路径判定）
│   ├── agents/                 # subagent（上下文隔离）
│   └── settings.json           # hook门禁
├── templates/                  # 4阶段产物模板
├── team-knowledge/             # 团队知识库
└── docs/versions/              # 每个需求的版本目录
```

### 核心创新：3条路径自动分流

```
新需求来了
    ↓
[/harness-req 自动判定]
    ↓
┌────┼────┐
↓    ↓    ↓
A    B    C
完整  小   Bug
需求  需求  修复
4阶段 2阶段 专项
```

| 路径 | 适用 | 阶段数 | 典型耗时 |
|-----|------|------|---------|
| A | 新功能/独立模块 | 4 | 30-90分钟 |
| B | 改文案/配置/小字段 | 2 | 5-15分钟 |
| C | bug/异常/报错 | 4 | 15-60分钟 |

---

## 📂 仓库结构

```
harness-lite/
├── docs/                      # 产品文档
│   ├── 00-product-spec/        # 产品规格
│   ├── 01-installation/        # 安装指南
│   ├── 02-daily-usage/         # 日常使用
│   ├── 06-skill-reference/     # skill手册
│   └── 07-evolution/           # 演进机制
├── templates/                  # 模板（init.sh复制源）
│   ├── CLAUDE.md
│   ├── .claude/
│   ├── templates/              # 产物模板（A/B/C路径）
│   └── team-knowledge/
├── scripts/                    # 自动化脚本
│   ├── init.sh                 # 智能初始化
│   ├── validate.sh             # 自检
│   ├── uninstall.sh            # 卸载
│   └── upgrade.sh              # 升级（v1.0.9+ 可用）
├── examples/                   # 示例项目
├── backlog/                    # 反馈与提议
├── VERSION
├── CHANGELOG.md
└── LICENSE
```

---

## 📚 文档导航

| 我想... | 看哪份文档 |
|--------|-----------|
| 知道这是什么 | [产品愿景](docs/00-product-spec/01-vision.md) ✅ |
| 知道值不值得用 | [价值主张](docs/00-product-spec/02-value-proposition.md) ✅ |
| 知道适不适合我 | [目标用户](docs/00-product-spec/03-target-users.md) ✅ |
| 知道做什么不做什么 | [产品边界](docs/00-product-spec/04-scope-boundary.md) ✅ |
| 5 分钟装起来 + 第一次用 | [快速上手](docs/01-getting-started/01-quickstart.md) ✅ |
| 路径 A/B/C 怎么选 | 📝 待补（v1.1） |
| 5 个 skill 详细用法 | 📝 待补（v1.1） · 暂时直接读 `.claude/skills/*/SKILL.md` |
| 升级 / 卸载 | 直接跑 `scripts/upgrade.sh` 或 `scripts/uninstall.sh` |
| 看历史变更 | [CHANGELOG.md](CHANGELOG.md) ✅ |

> 📝 待补：路径选择手册 / skill 参考 / 工作流总览 / 速查表 / 升级指南。
> 写作策略：等 stock_make_money 等真实项目实战暴露具体痛点后再写，避免凭想象产出无效文档。

---

## 🎓 设计基础

本产品站在以下巨人的肩膀上：

| 来源 | 借鉴的精华 |
|-----|----------|
| 《AI编程时代的软件工程V1.0》 | 上下文工程方法论 |
| PSC Team Harness | 完整的Harness方法论 + 7工序25活动 |
| AI-TDD-Harness | 路径分级 + 多Agent协作 + 验收分层 |
| Claude Code TDD (alexop.dev) | Skills + Subagents + Hooks |

致谢上述贡献者。

---

## 🛣️ 路线图

```
v1.0 (当前) — Team Small (2-5人)
   ├── 4阶段产物链路 (A路径)
   ├── 3核心skill + 4 subagent
   └── 知识库基础版

v1.1 (规划中) — Team Medium (6-15人)
   ├── 角色体系
   ├── 扩展skill
   └── 完整知识蒸馏流水线

v1.2 (远期) — Team Large (16-30人)
   ├── 多项目支持
   └── 跨项目知识库

v1.3 (远期) — Solo Edition (个人版)
   └── 从Team Small裁剪

v2.0 (远期) — 重大重构（如需）
```

详见：[CHANGELOG.md](CHANGELOG.md)（按 SemVer 规范，已发布版本细节）

---

## 💬 反馈

欢迎通过以下方式参与：

- 🐛 Bug报告：[GitHub Issues](https://github.com/wuxiongwei/harness-lite/issues)
- 💡 新能力提议：写入 [backlog/proposals.md](backlog/proposals.md)
- 📝 使用反馈：写入 [backlog/feedback.md](backlog/feedback.md)

---

## 📜 许可

[MIT License](LICENSE)  © 2026 wuxiongwei

---

*Harness-Lite v1.0.0-alpha · 2026-06 · Made with care*
