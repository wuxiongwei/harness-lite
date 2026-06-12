# 变更日志

> 本文档记录 Harness-Lite 的所有重要变更。
> 遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

格式说明：
- `Added` 新增功能
- `Changed` 已有功能的变更
- `Deprecated` 即将废弃的功能
- `Removed` 已移除的功能
- `Fixed` Bug修复
- `Security` 安全相关修复

---

## [Unreleased]

（暂无）

---

## [1.0.1] - 2026-06-12

### Fixed (基于 dogfooding 发现，走完整路径C流程修复)

- **init.sh sed 转义错误（P0）**：sed 分隔符 `|` 与替换值中的 `|` 冲突导致脚本崩溃。修复：分隔符改为 `#`，替换值的 `|` 改为 `/`
- **uninstall.sh 残留空 .claude/ 目录（P2）**：卸载后 `.claude/` 父目录未清理。修复：末尾追加 `rmdir ".claude"`
- **init.sh 末尾 unary operator 错误（P3）**：`$needs_backup` 局部变量被跨函数访问。修复：改为全局变量 `INSTALL_HAD_BACKUP`
- **init.sh banner ANSI 转义未渲染（P3）**：`cat << EOF` 不解析 `\033`，颜色变量显示为字面量。修复：简化 banner，改用 `echo` + `log_info`

### Added

- **首次 dogfooding 产物**：`docs/versions/active/v1.0.1-fix-init-bugs/`（01-复现 / 02-根因 / 03-修复 / 04-回归 完整四阶段）
- **harness-lite 自用配置**：根目录 `CLAUDE.md`（自用版，区别于 templates/CLAUDE.md）+ `.claude` 符号链接到 `templates/.claude`
- **dogfooding 元发现**：路径C对小bug显得过重 / 缺少自动化回归脚本（已加入 backlog/proposals.md）

### Changed

- 安装后 banner 简化：去掉 box-drawing 边框和颜色变量，改用 echo + log_info 组合（更兼容、更清爽）

---

## [1.0.0-alpha] - 2026-06-12

### Added
- 项目立项：Harness-Lite 产品诞生
- 核心决策：MVP聚焦 Team Small (2-5人)
- 设计基础：参考 PSC Harness 完整方案 + AI-TDD-Harness 实战经验
- 三大创新点：路径分级 / 多Agent协作 / 验收分层

### 项目背景
本产品基于以下方法论与实战经验：
- 《AI编程时代的软件工程 V1.0》(科大讯飞)
- PSC Team Harness (KS-AI-READY)
- AI-TDD-Harness (ai_sales_agent)
