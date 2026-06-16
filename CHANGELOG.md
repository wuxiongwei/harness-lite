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

## [1.0.8] - 2026-06-16

### Fixed (P2 · uninstall 残留)

- **`uninstall.sh` 自 v1.0.2 后未回归**：v1.0.2 加 hooks、v1.0.5 加 block-push.sh / distill-prompt.sh、v1.0.7 加 harness-impact / harness-test-ci，但 uninstall.sh 一直停留在"3 skills + 4 agents + 0 hooks"的旧版认知。残留 5 类：
  - `.claude/skills/harness-impact/`（v1.0.2 起残留）
  - `.claude/skills/harness-test-ci/`（v1.0.2 起残留）
  - `.claude/hooks/pre-commit-test.sh`（v1.0.2 起残留）
  - `.claude/hooks/block-push.sh`（v1.0.5 起残留）
  - `.claude/hooks/distill-prompt.sh`（v1.0.5 起残留）
- **修复**：补全卸载清单（5 skills + 4 agents + 3 hooks + 3 templates + 3 rules + settings.json），并 `rmdir .claude/hooks/` 清理空目录
- **预告显示**：用户 confirm 提示文案从"3 个 skill"改为"5 个 skill"+ 新增"3 个 hook 脚本"行

### Verified

- 实测 install → uninstall 干净循环：26 个文件装上、26 个全清，`.claude/` 父目录也回收，CLAUDE.md / docs / team-knowledge 等用户数据按设计保留

---

## [1.0.7] - 2026-06-16

### Fixed (P1 · v1.0.5 同根 bug 全面爆发)

- **5 个 skill frontmatter 用了不存在的字段**：`trigger.keywords` / `trigger.patterns` / `version` 都是凭印象写的，Claude Code 不认。改为：
  - 删 `trigger` / `version`
  - 把"何时触发"语义全部融入 `description`（这才是 Claude 自动选用 skill 的依据）
  - 受影响：harness-req / harness-design / harness-impact / harness-review / harness-test-ci
- **4 个 agent frontmatter 用了自造字段**：`visible:` / `invisible:` 不在官方支持的字段列表里。改为：
  - 删 `visible` / `invisible`
  - 加 `tools:` 字段（官方支持，限制工具调用范围）
  - "可见范围"语义下放到 system prompt body（LLM 读到会主动遵循）
  - 受影响：doc-generator / implementer / reviewer / validator
- **57 处 skill 调用名错误**：`/harness:req` → `/harness-req`（冒号是 plugin 命名空间专用，项目级 skill 调用名 = 目录名）
  - 替换范围：`templates/.claude/skills/*` (49 处) + `templates/CLAUDE.md` / `scripts/init.sh` / `README.md` / `CLAUDE.md` (8 处)
  - 历史版本目录 `docs/versions/active/v1.0.{1,2,3,5,6}-*/` 保持不动（历史档不动）

### Added (横向预防)

- **`validate.sh` skill / agent schema 校验**：v1.0.6 settings 防回归网扩展到 skill / agent：
  - skill 不含废弃字段 `trigger:` / `version:`
  - agent 不含废弃字段 `visible:` / `invisible:`
  - skill 必须含 `description:`（触发关键）
  - 全文档不残留旧调用名 `/harness:`
- **dogfooding 元发现回流**：识别出"dogfooding 期间从未在 claude REPL 敲过 skill 命令"是漏 bug 的根因，已写入 backlog（下版本起，dogfooding 协议必须包含敲一次命令）

### Changed

- **stock_make_money 现场同步**：`.claude/skills/` + `.claude/agents/` 全量覆盖，`CLAUDE.md` 修 5 处旧调用名

---

## [1.0.6] - 2026-06-16

### Added (v1.0.5 元发现回流)

- **`validate.sh` schema 校验**：新增 settings.json schema 5 条不变式校验（jq 实现），可主动捕获 v1.0.5 类 schema 漂移：
  1. `permissions.allow` 是数组
  2. `permissions.deny` 是数组
  3. 没有遗留字段 `alwaysAllow`/`alwaysDeny`
  4. hook entry 的 `matcher` 是字符串
  5. hook entry 的 `hooks` 是数组
- **降级路径**：jq 未安装时降级为 `python json.tool` 仅校验语法，并提示 `brew install jq`
- **`init.sh` 安装完成提示重排**：把"启动 claude 自检"提到 #1（明确说"看到红色 Settings Error 立即报告"），防止 schema 错误被静默跳过

### Changed

- **测试覆盖**：手测在干净安装、坏 schema（恢复 v1.0.4 旧格式）两种场景下，validate.sh 输出符合预期

---

## [1.0.5] - 2026-06-16

### Fixed (P0 · stock_make_money 现场暴露)

- **`settings.json` schema 不兼容 Claude Code**：旧 schema 使用 `alwaysAllow`/`alwaysDeny` + `matcher: object` + `action: block_unless_pass`，导致 `claude` 启动时报 "Settings Error · hooks: Expected array, but received undefined"。改用 Claude Code 当前 schema：
  - `permissions.allow` / `permissions.deny`：字符串数组，格式 `"Bash(git status:*)"` / `"Edit(**/.env)"`
  - `hooks.{Pre,Post}ToolUse`：每项含 `matcher`（工具名字符串如 `"Bash"`）+ `hooks` 数组（含 `type`/`command`，按需加 `if`）
  - 用脚本 `exit 2` 阻塞工具调用（不再用 `action` 字段）

### Changed

- **`pre-commit-test.sh` 退出码**：失败时 `exit 1` 改为 `exit 2`（Claude Code PreToolUse 阻塞约定），并向 stderr 输出阻塞原因
- **新增 `block-push.sh`**：原本嵌入 `settings.json` 的"禁止 AI push"逻辑独立成 hook 脚本（exit 2 阻塞）
- **新增 `distill-prompt.sh`**：原本嵌入 settings.json 的"04-*.md 写完提示蒸馏知识"逻辑独立成 hook 脚本

---

## [1.0.4] - 2026-06-15

### Added

- **`init.sh` 项目信息自动提取**：新增 `extract_project_name` / `extract_tagline` / `extract_business_desc` 三个函数。从 `README.md` / `pyproject.toml` / `package.json` 按优先级抽取项目名、tagline、业务描述。已有项目装上去，用户大多数字段直接回车采纳即可，不再需要手敲

### Fixed

- **macOS bash 3.2 `read -p` 中文乱码**：提示词末尾紧跟「`$变量` + 中文括号」时，bash 3.2 的 readline 会在 UTF-8 边界吃掉部分字节，导致 `项目名（默认 ��:` 这类显示。改用 `printf` 提前打提示词、`read` 不带 `-p` 单独读输入

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
