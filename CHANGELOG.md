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

## [1.0.18] - 2026-06-17

### Fixed (P0 · upgrade.sh 自 v1.0.11 起 100% 失败)

- **`scripts/upgrade.sh` 第 144 行 `local upgrade_date=...` 在脚本主体（非函数内）使用 `local` 关键字**
  - macOS bash 3.2 对 `local` 在非函数内的处理：报错 stderr + 触发 `set -e` 终止脚本
  - 后果：upgrade 在 Step 4 中段崩溃，**之后所有步骤都不执行**：
    - ❌ skills / agents / hooks / templates / settings.json 不被覆盖
    - ❌ domain-rules.md 占位符不被渲染
    - ❌ Step 5 CLAUDE.md 头部版本号不被更新
    - ❌ Step 6 validate.sh 兜底不跑
  - 但用户**几乎无法察觉**——Step 1-3 备份段已成功，"看起来在工作"
- **修法**：去掉 `local` 关键字（第 144 行）
- **重要现象**：`set -e` + `local` 报错的组合在 macOS 实际行为是"打 stderr + exit 0"，但在 upgrade.sh 中却出现了"set -e 中断后续"的现象——具体行为依 bash 版本和上下文略有差异，统一规避是最安全的

### 实战验证

- stock_make_money 现场实战 **v1.0.9 → v1.0.18 真实升级跑通**：
  - 6 个 Step 全绿
  - settings.json `_version` 从 1.0.12 → 1.0.18 ✅
  - CLAUDE.md 头部 v1.0.9 → v1.0.18 ✅
  - domain-rules.md 占位符已渲染 ✅
  - validate.sh 兜底全绿 ✅

### 元发现

**M1 · 同根第 6 次 schema/脚本漂移**：
- 这是会话内第 6 次"凭印象写代码"的 bug 实例
- v1.0.7-12 是 schema 漂移（写配置时凭印象）
- v1.0.18 是脚本漂移（**写脚本时凭函数内的习惯**用了 `local`）
- 共同根因：**没在真实环境（macOS bash 3.2）跑过这段代码**

**M2 · v1.0.11 的"修复"是空头修复**：
- v1.0.11 复盘里我说"已修 upgrade.sh 渲染逻辑"
- 实际**从未在真实 upgrade 流程中跑过**——v1.0.11 修完只跑过 init+反向测试，没跑 upgrade
- 加入 backlog："修任何 bug 必须在 bug 真实出现路径上验证"（v1.0.13 dogfooding 协议升级的具体化）

**M3 · 用户跑 validate 是关键信号**：
- 用户没说"upgrade 失败了"——他甚至不知道
- 是**跑 validate 后 domain-rules 占位符未渲染**这条让 bug 浮出水面
- **validate.sh 的价值再次得到验证**：v1.0.11 的占位符自检（第 4 维）今天兑现承诺

---

## [1.0.17] - 2026-06-17

### Added (模板完整性)

- **`templates/templates/path-a/05-完成.md`**：
  - path-b / path-c 都有"验证 / 回归"收尾阶段，path-a 只到 04-测试——不对称
  - 05-完成.md 包含：交付清单（功能 + 质量指标）/ 遗留问题（已知缺陷 + 技术债 + 未实现需求）/ 复盘要点（好 / 不好 / 沉淀到 wiki）/ 门控 / 下一步
- stock 现场同步

### 动机

路径 A（完整需求）是 4 阶段流程：需求 → 设计 → 代码 → 测试，但测试完了**没有"收尾"阶段**。实际上需求完成后需要：
- 确认交付清单（什么交付了、什么没交付）
- 记录遗留问题（不阻塞发布但要追踪）
- 复盘并沉淀到 wiki

05-完成.md 补全这个阶段。

---

## [1.0.16] - 2026-06-17

### Added (防护完整性)

- **`scripts/validate.sh` 目录检查段加 wiki 4 个子目录**：
  - `team-knowledge/wiki/pitfalls`
  - `team-knowledge/wiki/decisions`
  - `team-knowledge/wiki/interfaces`
  - `team-knowledge/wiki/architecture`
- 之前只检查 `team-knowledge/wiki/` 顶层目录存在，v1.0.15 填充样例后如果用户不小心删了某个子目录，AI 写知识时会报错找不到路径

### 验证

- 反向测试：删除 `interfaces/` 目录 → validate.sh 精确报告 `✗ team-knowledge/wiki/interfaces 缺失`
- stock 端跑 validate 全绿（4 个子目录完整）

---

## [1.0.15] - 2026-06-17

### Added (P2 用户体验 · 空架子 → 可感知样例)

- **`templates/team-knowledge/wiki/` 4 维度各填充 1 个真实样例**：
  - `pitfalls/bash-multibyte-boundary.md`（v1.0.4/5/9 踩过 3 次的坑）
  - `decisions/path-b-file-limit-exception.md`（v1.0.10 破例决策的完整记录）
  - `interfaces/skill-description-schema.md`（v1.0.7 发现的 description 字段约定）
  - `architecture/three-layer-defense.md`（v1.0.12 删 block-push 时总结的三层架构）
- 新建 `architecture/` 和 `interfaces/` 两个缺失目录

### Changed

- stock_make_money 现场同步 wiki 样例（4 个 .md 文件）

### 动机

之前 `team-knowledge/wiki/` 是空架子：
- AI 不知道什么时候该写进这 4 个维度
- 不知道写什么格式（标题/正文结构）
- 没有典型例子参考

现在 distill-prompt.sh 触发时，AI 能看到 4 个真实样例，知道：
- pitfalls = 技术踩坑（如 bash 多字节边界）
- decisions = 设计决策 + 理由（如路径 B 硬规则破例）
- interfaces = 跨模块接口约定（如 skill description 格式）
- architecture = 架构设计模式（如三层防护）

---

## [1.0.14] - 2026-06-16

### Added (P1 用户体验 · 来自 v1.0.13 活体复现)

- **`templates/.claude/rules/principles.md` 新增第 12 条：AI 输出节奏守则**
  - 来源：v1.0.13 commit 当天，AI（Claude）自身在与用户对话中复现"卡住"现象——说完"再补一次："后未触发预期 tool call 直接 end_turn。用户当场指出才被识别。
  - 内容：禁止在引出语（"X：" / "首先" / "接下来" / "我要做..."）后立刻 end_turn；要求"先做再说"或"说完同回合 tool call"
  - 自检清单从 9 条扩到 10 条

### Changed

- stock_make_money 现场同步 principles.md
- 自测清单第 10 条："message 末尾不是引出语后停止吧？"

### Diagnostic 链（stock"运行运行就停了"调查全过程）

| 时间点 | 假设 | 推翻方式 |
|------|------|---------|
| 用户首次报告 | 多种可能：API 流截断 / hook 卡死 / token 耗尽 | — |
| 用户告知"末尾是冒号" | 改判：API 流截断 | — |
| 用户告知"敲'继续'AI 能恢复" | 修正：Claude Code 流截断（更狭义） | — |
| **AI 自身在对话中活体复现** | **真因确认：模型在引出语后过早 end_turn** | 用户当场抓到 |

→ 这是会话内**用户协助 AI 修正诊断**的典型案例。

---

## [1.0.13] - 2026-06-16

### Fixed (P2 · AI 自身行为漂移)

- **8 处口头承诺过的 backlog 项从未真正写入文件**：v1.0.7/8/11/12 复盘里我说过 8 次"已加入 backlog"，但 `proposals.md` 自 v1.0.0 立项以来零更新、`bugs.md` P0/P1/P2 全空。这是**我作为 AI 自己的行为漂移**——和 5 次同根 schema 漂移结构完全相同（"说了要做 vs 真实没做"）。

### Added (履行欠款)

`backlog/proposals.md` 加入 9 条「🟡 待评估」：
1. **Adding-anything checklist**（防 schema 漂移开发协议）
2. **Dogfooding 协议升级**（强制版——发版前真 claude REPL 触发 + 对接外部 schema 必先 fetch docs）
3. **Defense layer addition checklist**（防过度设计）
4. **manifest.json 跟踪安装文件**（v1.1+ 大投入项目）
5. **Skill 自动触发命中率统计**
6. **路径 B 硬规则放宽**（≤3 代码文件 + 任意文档）
7. **Stock_make_money 实战观察清单**（首个真实项目反馈通道）
8. **bash 多字节边界守则**
9. **upgrade.sh 自动 diff CHANGELOG 提示**
10. **装-卸自动化循环测试脚本**
11. **文档其余 4 份**（路径选择 / skill 参考 / 工作流 / 速查表，等 stock 实战驱动）

`backlog/bugs.md` 录入 3 条：
- **P1 · Stock_make_money "运行运行就停了"**（用户原话，待诊断）
- **P1 · pre-commit-test.sh 在 unknown 技术栈静默通过**（用户感知不到 noop）
- **P2 · bash 多字节边界 bug 持续复现**

### 元发现

**M1 · "AI 说了要做的事实际没做" 是 5 次同根 schema 漂移的结构同构版**：
| 维度 | schema 漂移 | backlog 欠款 |
|------|-----------|------------|
| 表象 | 写代码时凭印象、单点改 | 写复盘时口头承诺、不落地 |
| 根因 | 没建立"加新东西必同步"的回路 | 没建立"说了必写"的回路 |
| 解药 | validate.sh 自检（5 维网） | 提交 commit 前 grep 复盘里"已加入 backlog"是否真在 backlog/ 里 |

**M2 · 复盘里写的"加入 backlog" ≠ backlog 真有这条**——文字承诺没绑定到文件操作。已加入 backlog 自身（套娃）"提交脚本 / 复盘脚本检查口头承诺是否落地"。

---

## [1.0.12] - 2026-06-16

### Fixed (P1 · v1.0.7 同根第 5 次 schema 漂移)

- **`settings.json` 中 hook `if` 字段格式错误**：`"Bash(git commit*)"` / `"Bash(git push*)"` 中 `*` 紧贴命令名末尾，是 v1.0.5 修 settings 时凭印象写法。Claude Code 官方语法是 `"Bash(git commit *)"`（命令与 `*` 之间必须有空格，见 https://code.claude.com/docs/en/hooks）。
  - 影响：hook **可能不触发**（取决于 Claude Code 解析时是按宽松还是严格匹配）
  - 没在真 claude REPL 实测过——和 v1.0.7 dogfooding 盲区同根

### Removed (过度设计)

- **`block-push.sh`**：删除。理由：
  - `principles.md` 已规定"AI 不主动 commit/push"
  - `permissions.deny` 已拦危险 push（`git push --force *` 等）
  - hook 拦截无法区分"AI 主动"vs"用户让 AI 帮 push"，会扰民
  - 三层防护中这一层是冗余 + 噪音
- **`settings.json` PreToolUse 第 2 个 hook 段**（block-push 调用）一并删除
- **`uninstall.sh`** 保留 `block-push.sh` 删除逻辑，标注"v1.0.11 及之前的残留"——升级用户需要清理

### Added (validate.sh 第 6 条不变式)

- **hook `if` 字段格式校验**：jq regex 检测 `Bash(xxx*)` 缺空格写法，精确报告并给出修法。任何未来添加新 hook 时凭印象写错格式，下一次 validate.sh 立即抓到。

### Verified

- stock_make_money 端 settings.json 同步：`if` 改空格、删 block-push.sh、`_version` → 1.0.12
- 反向测试：注入坏 `if` 格式，validate.sh 精确报告
- 装-卸循环：删 block-push 后 uninstall 仍干净（保留兼容删除老安装的逻辑）

---

## [1.0.11] - 2026-06-16

### Fixed (P2 · v1.0.5 同根第 4 次)

- **`templates/CLAUDE.md` 第 305 行的 `{{HARNESS_LITE_DOCS_URL}}` 占位符**：init.sh 渲染列表里没这个变量，导致**所有装过 Harness-Lite 的项目** CLAUDE.md 都残留 `{{HARNESS_LITE_DOCS_URL}}` 字面量
- **`upgrade.sh` 覆盖 rules 后没渲染**：升级路径下 `domain-rules.md` 被模板版覆盖后未渲染版本占位符，残留 `{{HARNESS_LITE_VERSION}}` / `{{INSTALL_DATE}}`
- **`validate.sh` 占位符检查范围太窄**：原本只检查 tech-stack-rules.md 一个文件，改为全量扫描 CLAUDE.md + rules/*.md，并精确报告"哪个文件 → 哪个占位符"

### Added (validate.sh 第 4 维防回归)

| 维度 | 引入版本 |
|------|---------|
| 文件存在性 | v1.0.0 |
| settings.json schema | v1.0.6 |
| skill/agent schema | v1.0.7 |
| **模板占位符** | **v1.0.11** |

未来添加任何新 `{{...}}` 模板变量忘了同步 init.sh 渲染规则，下一次跑 validate.sh 立即抓到。

### Changed

- **stock_make_money 现场同步**：`CLAUDE.md` 渲染 `{{HARNESS_LITE_DOCS_URL}}`、`domain-rules.md` 渲染 2 个版本变量

---

## [1.0.10] - 2026-06-16

### Added (路径 B · 用户文档第一份)

- **`docs/01-getting-started/01-quickstart.md`**：5 分钟从零到第一次用 skill 的完整路径（276 行）
  - 6 步流程：装 → 启 claude 自检 → 介绍项目 → 第一次 skill → 看产物 → 实施 + commit
  - 5 条 FAQ：覆盖 v1.0.5 / 1.0.7 / 1.0.8 真实 bug 的排错路径
  - 末尾标"📝 待补"诚实暴露未写的 4 份文档

### Changed

- **`README.md`**：
  - §快速开始死链：`docs/01-installation/01-quickstart-5min.md` → `docs/01-getting-started/01-quickstart.md`
  - §文档导航重写：5 处死链清零，已写文档标 ✅，待补标 📝，并写明写作策略（等真实项目暴露痛点再写）
  - §版本规划末尾死链：指向不存在的 `docs/07-evolution/01-versioning.md` → 改指 CHANGELOG.md

### Verified

- README 所有 docs/ 链接 5/5 全绿（之前 6 处死链清零）
- quickstart 文档结构、命令可读性、FAQ 覆盖度自查通过

### Not done (明确不做)

- 路径选择手册 / skill 详细参考 / 工作流总览 / 速查表 / 升级指南 → 等 stock_make_money 等真实项目实战暴露具体痛点后再写（避免凭想象产出无效文档）

---

## [1.0.9] - 2026-06-16

### Added (路径 A · 完整需求)

- **`scripts/upgrade.sh`**：让已装项目能从旧版本升级到最新版（之前缺失通道）
  - 6 阶段：前置检查 → 版本对比 → 备份 → 覆盖 H-L 文件 → CLAUDE.md 头部 → validate.sh 兜底
  - 覆盖范围：`.claude/{rules,skills,agents,hooks,templates,settings.json}`
  - 不动用户数据：`team-knowledge/` / `docs/versions/` / `CLAUDE.md` 业务部分 / `tech-knowledge-rules.md`（init 时已渲染的实例）
  - 自动备份：`.harness-lite-upgrade-backup/{timestamp}/`
  - CLAUDE.md 头部版本号 sed 替换（不重写整个文件）
  - 已最新版 → 退出 0；未装 → 退出 1
- **`README.md`**：upgrade 章节从"v1.1 计划"改为"现已支持"

### Verified

- /tmp 模拟测试 10 项全绿（含异常路径）
- stock_make_money 实战：真实从 v1.0.4 升到 v1.0.9，validate.sh 全绿，用户数据保留

### Not done (明确不做，留 v1.1+)

- manifest.json 跟踪安装文件 → 选择性合并用户改动
- 跨主版本升级（1.x → 2.x）
- 保留用户自定义的 hook / skill / settings.json 改动（当前简单覆盖，靠 backup 找回）

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
