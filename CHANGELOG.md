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

## [1.0.3] - 2026-06-15

### Added

- **Lite 档解锁**：`init.sh` Step 3 选 `1` 时正式生效（TIER=lite，团队规模 1-3 人），不再强制转 standard。Lite 与 Standard 在能力上相同，差异仅体现在 CLAUDE.md 元信息字段，避免为不存在的差异维护多套模板（principles §2 最小化实现）

### Changed

- **`init.sh` 项目信息默认值**：
  - `PROJECT_NAME` 默认 = `basename($TARGET_DIR)`（取当前目录名），不再让用户重复输入
  - `TEAM_SIZE` 默认根据 TIER 自动给（lite→"1-3人" / standard→"4-10人"），不再硬编码
  - 所有 `read -p` 提示词标注当前默认值，让"全程空回车"成为可行路径
- **Pro 档文案**：从"v1.1 计划支持，当前不可用"改为"v1.1 计划支持，当前安装为 Standard 档"（更准确——选了不会报错，会自动降级）

---

## [1.0.2] - 2026-06-14

### Added（回归保障能力体系）

- **`/harness:test-ci` skill**：全量回归 CI skill，自动检测测试框架（Python/Java/Node.js/Go），全量运行测试，输出分层报告（Layer 1/2/3），门控信号 PASS / BLOCKED。支持渐进模式（`--progressive`，老项目"改哪测哪"）
- **`/harness:impact` skill**：影响面分析 skill，基于 `git diff` 找改动文件，静态分析调用关系（import/require 扫描），输出直接/间接依赖清单 + 测试覆盖情况，与 `/harness:test-ci` 协同使用
- **`.claude/hooks/pre-commit-test.sh`**：全量测试 pre-commit hook 标准模板，技术栈自动检测，含"项目定制区"，支持 `HARNESS_SKIP_TEST=1` 临时跳过，非阻塞 lint + 阻塞测试
- **`principles.md §11`**：全量回归铁律，明确规定"AI 改完代码必须跑全量测试"，自测清单从 8 条升至 9 条

### Fixed

- **`init.sh` 智能合并**：当目标项目已有 `.claude/` 时，不再创建 `.claude.harness-lite-new/` 要求用户手动合并。改为智能注入：rules 覆盖（产品管理）、skills/agents/hooks 追加（用户已有文件保留），settings.json 仅在不存在时创建

### Changed

- **`settings.json`**：`git commit` hook 从"仅提醒"改为"调用 pre-commit-test.sh 门禁"，确保测试不通过不能 commit
- **`validate.sh`**：新增 `harness-test-ci/SKILL.md` 和 `hooks/pre-commit-test.sh` 的存在性检查



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
