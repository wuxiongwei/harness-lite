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

## [1.0.24] - 2026-06-18

### Fixed (P1 · v1.0.23 M1 实锤 · 协议落地 vs 实施层 gap)

> **不 push GitHub**（沿用 v1.0.23 用户指定）

#### 验证暴露的真相

用户要求"用 example 自己验证 v1.0.23 多人协同" → 创建 `examples/multi-team-demo` 模拟 3 人场景 → 审视过去 21 个版本：

| 版本 | 应记决策点 | 实际记录 |
|-----|----------|---------|
| v1.0.21（4 次方向纠偏 + 5 个 D） | 9+ 条 | 0 条 |
| v1.0.22（文档撰写期间细节决策） | 5+ 条 | 0 条 |
| v1.0.23（4 次 AskUserQuestion + 8 个 D） | 12+ 条 | 0 条 |

**实锤**：协议存在 ≠ 协议被遵循（系统性，不是偶然）。

#### 修复（用户拍板 A · 软约束）

- **`templates/.claude/rules/principles.md` +§13.1.1 决策点识别示例**（+110 行）
  - 8 个真实场景示例（AskUserQuestion 触发 / "X 还是 Y" 对比表 / 来回讨论 / N 选 1 / 阈值 / 命名 / yes-no / 隐式决策）
  - §13.1.2 自检清单（6 条问句 + "任一为是 → log 必须写"）
- **5 个 skill body 加 "v1.0.24 强约束" 段**：
  - harness-req（详细版 +12）
  - harness-design / harness-impact / harness-review / harness-test-ci（精简版 +5 各，引用 §13.1.1）
- **顺手修符号链接边界 bug**：
  - `.gitignore` 加 `templates/.claude/decision-log.md` 和 `auto-decide.md`
  - 解决 H-L 仓库 dogfooding 时（`.claude → templates/.claude`）gitignore 规则被绕过

#### 实测协议**首次真触发**

修复后立刻：
```bash
$ cat .claude/decision-log.md
## v1.0.24 path-c · 修复强度
- 用户答：A 补示例纲领（软）
## v1.0.24 · 验证场景 · multi-team-demo 设计
- AI 自决：B + A
## v1.0.24 · 修复方案
- 用户答：A
```

**3 条记录** —— 这是 H-L 仓库**首次真触发**协议自动写入（21 个版本以来）。

### Added · examples/multi-team-demo

- 3 人模拟场景（alice / bob / zoe）
- 各自 assignments + 故意违规分支名
- 留作后续 dogfooding 测试基底

### 元发现

- **M2 · 软约束 + 示例 = 协议层产品的关键**：协议本身存在不够，必须配"识别示例"+"自检清单"
- **M3 · dogfooding 价值再次实锤**：每次大协议改动必须 dogfood，否则等用户反馈才发现 gap
- **M4 · dogfooding 顺手暴露周边 bug**：符号链接 + gitignore 边界问题在写 log 时被发现

### 三件套原则（沉淀到 backlog）

未来任何**协议层版本**必须三件套齐备：
1. 协议本身（描述）
2. 实施约束（强约束 / Phase checklist）
3. 示例兜底（让 AI 识别具体场景）

缺一不可。

### Verified

- principles §13.1.1 含 ≥ 8 识别示例 ✅
- §13.1.2 自检清单 ≥ 6 条 ✅
- 5 skill 都加强约束段 ✅
- .gitignore 符号链接边界生效 ✅
- **协议首次真触发**：H-L 仓库 .claude/decision-log.md 含 3 条 ✅
- stock 现场同步 6 文件 + validate 全绿 ✅

### Not done

- 不加 SubagentStop hook（C 强约束选项）—— 留备份
- 不修改 v1.0.21 / v1.0.23 协议本身 —— 只补示例 + 自检
- 待 stock 实测：v1.0.24 强约束是否真让 AI 在后续 path-a 自动写 log

---

## [1.0.23] - 2026-06-18

### Added (Standard 协同机制 · principles §14 多人协同协议)

> **不 push GitHub**（用户指定，本地 commit 保留）

#### Layer 1 协议层
- **`templates/.claude/rules/principles.md` 新增 §14 多人协同协议**（+67 行）
  - §14.1 三类协同问题与对策（并行不冲突 / 责任不重复 / 角色协同）
  - §14.2 关键文件（`branch-strategy.md` + `assignments/<人>.md`，**入仓库**）
  - §14.3 软约束原则（不动 git hook）
  - §14.4 检查触发点（commit/push 前 + harness-req 创建版本前 + harness-impact 中）
  - §14.5 协同视角原则（≥2 条具体可执行）
  - §14.6 与 §13 / 铁律优先级（铁律 > §13 > §14）
  - §14.7 文件不存在 = v1.0.22 行为
  - 自检清单从 11 条扩到 12 条

#### Layer 2 数据层（团队共享，**入仓库**）
- **`templates/.claude/branch-strategy.md` 新增**（+59 行）：通用模板 + 命名规范 + 主分支保护 + 合并规则 + 示例 + 团队自定义占位
- **`templates/.claude/assignments/.gitkeep`** + **`templates/.claude/assignments/README.md`**（+94 行）：任务认领板说明 + AI 行为约定 + 多 owner 协作

#### Layer 3 流程层
- **4 skill body 接入协同视角段**（+123 行总计）：
  - `harness-req`：Phase 5.7 + A2 任务冲突预警（claim 冲突时 [1]协作 [2]改名 [3]取消）
  - `harness-design`：Phase 4.7（PM + QA 视角）
  - `harness-impact`：Phase 3.7 + A3 文件冲突预警（与 assignments 交叉）
  - `harness-test-ci`：Phase 4.7（PM + RD 视角）

#### .gitignore（+5 行注释）
- 与 v1.0.21 决策学习对比：v1.0.23 文件**入仓库**（团队共享）

### Changed
- **`scripts/init.sh` UX 修复**："🆘 遇到问题：" → "🛠️ 常用工具："
  - 旧文案 SOS 表情让用户误以为安装失败
  - 改为"工具型表情"+ 工具列表，把"事后补救"框架改为"日常工具箱"
  - 顺手补齐 upgrade.sh 入口（之前漏列）

### 价值

**Standard 档真正落地**——从 v1.0.0 的"档位营销标签"，到 v1.0.23 的**多人协同基础设施**：
- 并行不冲突（A1 分支策略 + A2 任务认领 + A3 文件冲突预警）
- 责任不重复（assignments 多 owner 支持）
- 角色协同（4 skill 协同视角段）

**协同 ≠ 分工**——不做工业化分工（v1.0.21 v1 已废），做协同基础设施。

### 元发现 M1 · 协议落地 vs 实施层 gap（最重要 · 触发 v1.0.24）

v1.0.21 决策学习协议虽然写入 principles §13，**但本次 v1.0.23 自身的 13 个决策点全部由 AskUserQuestion / AI 自决处理，无一条写入 decision-log.md**。

**根因**：协议规定"AI 遇到决策点 → 询问 + 记 log"，但 AI 在生成 markdown 文档时**没把"和用户讨论方向"识别为决策点**。

**这是协议层产品的核心挑战**：协议存在 ≠ 协议被自动遵循。

**修复方向**（v1.0.24，已加任务）：
- 加强 principles §13 中"如何识别决策点"的示例
- SKILL.md 模板约束："调 AskUserQuestion 前 / 后必须 append decision-log"

**沉淀**：协议层产品有 3 层级，缺一不可：
1. 协议本身（描述）
2. 实施约束（自动触发场景）
3. 示例兜底（让 AI 识别具体场景）

### 兼容性

- v1.0.22 升级到 v1.0.23：渐进启用，无 breaking change
- `branch-strategy.md` 不存在 → 跳过分支检查（同 v1.0.22）
- `assignments/` 不存在 → 跳过冲突预警（同 v1.0.22）
- 协同视角段：默认开启（无依赖文件）

### Verified

- 静态审计通过（principles §14 / 5 文件接入 / .gitignore 全 ✅）
- 8 个矩阵测试推演通过（T1-T8）
- 4 skill 协同视角内容质量验证（每视角 ≥ 2 条具体提醒，防 R4 流于形式）
- stock 现场同步并 validate 全绿
- 风险 R1-R5 全部缓解

### Not done (留 v1.0.24+)

- 修复 M1 协议落地 vs 实施层 gap（v1.0.24 优先）
- C 类知识协同（共享 wiki / 架构 ADR / 设计评审协作）→ v1.0.24+ 单独大版本
- 强制 git hook 分支校验 → v1.1+
- 任务依赖图 / 时间线 → v1.2+

---

## [1.0.22] - 2026-06-18

### Added (task #9 落地 · pending 12 版本后兑现)

- **`docs/02-skill-reference/` 6 篇文档（共 996 行）**：
  - `00-decision-learning-guide.md`（260 行）—— v1.0.21 决策学习协议使用指南，v1.0.21+ 用户必读
  - `01-harness-req.md`（145 行）—— 主入口 skill 手册
  - `02-harness-design.md`（132 行）—— 设计阶段 skill 手册
  - `03-harness-impact.md`（146 行）—— 影响面分析 skill 手册
  - `04-harness-test-ci.md`（156 行）—— 全量测试 skill 手册
  - `05-harness-review.md`（157 行）—— 一致性审计 skill 手册
- **统一 9 段模板**：定位 / 场景 / 调用 / 范例 / 决策点 / 做什么不做什么 / FAQ / 协作 / 进阶
- **README 文档导航更新**：6 行新链接，删除"5 skill 详细用法 📝 待补"占位

### 时机选择（task #9 等了 12 个版本）

为什么不在 v1.0.10 写：
- 当时 skill 内容仍频繁变化
- v1.0.7 改 frontmatter / v1.0.19 改阶段数 / v1.0.21 加 Phase X.5

为什么 v1.0.22 是对的时机：
- v1.0.21 协议层落地 → 内容稳定
- v1.0.20 md-counter 示例 → 有真实使用案例
- 决策学习协议给"用户视角"提供骨架
- 历史协议变化已收敛

### 元发现

- **M1 · 文档时机**：v1.0.10 立的"等真实项目实战暴露痛点再写文档"原则正确。强行早写会频繁返工
- **M2 · 文档统一模板**：5 篇 skill 手册用同一 9 段结构，避免风格漂移 + 新加 skill 直接套模板
- **M3 · 协议层产品必须有指南**：v1.0.21 协议层改动，没有用户指南用户会困惑（什么是 decision-log / auto-decide / 自决标注）。已沉淀

---

## [1.0.21] - 2026-06-18

### Added (Lite 自动化做透 · principles §13 决策学习协议)

- **`templates/.claude/rules/principles.md` 新增 §13 决策学习协议**（+74 行）
  - §13.1 决策点定义（≥2 个合理选项的子问题）
  - §13.2 处理流程（查 auto-decide → 命中自决+标注 / 未命中询问+记 log）
  - §13.3 自决标注（必做：含撤回路径）
  - §13.4 复盘触发（自动 05-完成 + 手动关键词）
  - §13.5 与铁律优先级（铁律不可被偏好覆盖）
  - §13.6 文件位置（.gitignore 默认）
  - 自检清单从 10 条扩到 11 条
- **5 个 skill body 接入决策点处理**：
  - harness-req：Phase 5.5（详细版 +62 行，含完整流程示例）
  - harness-design：Phase 4.5（精简 +13 行）
  - harness-impact：Phase 3.5（精简 +11 行）
  - harness-review：Phase 3.5（精简 +11 行）
  - harness-test-ci：Phase 4.5（精简 +11 行）
- **`templates/templates/path-a/05-完成.md` 新增"决策回顾"段**（+52 行）
  - 4 步执行流程：读 log → 批量授权对话 → 处理 a/s/d → 清理
  - 批量操作语法：`1=a,2=s,3=a` / `all=a` / `quit`
- **`.gitignore`**（+4 行）：`.claude/decision-log.md` 和 `.claude/auto-decide.md` 默认不入团队仓库

### 价值

**Lite 档真正升级**——AI 老实问、老实记，迭代结束时一次复盘批量授权。
- 用户单次决策时不疲劳
- 复盘时看全景做决策
- 与 path-a 05-完成 阶段天然契合（不是平行模块）

### 设计哲学

| 维度 | v3 旧方案（已废） | v4 采用方案 |
|-----|---------------|------------|
| 触发 | 实时（每次决策都判断） | 延迟（迭代结束统一复盘） |
| 复杂度 | 高（信任度阈值、累积、匹配） | 低（老实问 / 老实记） |
| 用户视角 | 单点决策 | 批量决策（看全景） |

来自用户原话："每次完成一个迭代可以和用户讨论一下，下次哪些就不用询问那些还是要授权。"

### 元发现 · 4 次方向纠偏

- v1：角色分工（PM/RD/QA） → 用户："意义不大"
- v2：多视角增强 → 用户："Standard 才需要协同"
- v3：实时学习 → 用户："太复杂"
- **v4：延迟批量回顾** → 采用 ✅

**沉淀**：产品定位 / 复杂度 / 场景边界三类决策，用户视角永远胜过 AI 视角。已加入 backlog/proposals.md。

### 兼容性

- v1.0.20 升级到 v1.0.21：渐进启用，无 breaking change
- `.claude/auto-decide.md` 不存在 = v1.0.20 行为（直接询问）
- 用户首次答决策 → 自动创建 decision-log.md
- 完成首次 path-a → 触发首次复盘对话

### Verified

- 静态审计通过（principles §13 / 5 skill 接入 / 05-完成 段 / .gitignore 全 ✅）
- 9 个矩阵测试推演通过（T1-T9）
- stock 现场同步并 validate 全绿
- 风险 R1-R5 全部缓解（铁律保护 / 撤回路径 / 严格匹配 / 清理机制 / 必记清单）

### Not done (留 v1.2)

- LLM 智能匹配（当前用严格关键词匹配）
- 跨项目偏好继承（导入/导出）
- decision-log 自动归档（> 半年清理）

---

## [1.0.20] - 2026-06-17

### Added (任务 #10 · Standard 档示例项目)

- **`examples/md-counter/`**：path-a 5 阶段完整示例项目
  - 主题：Markdown 字数统计命令行工具（业务逻辑极简，聚焦流程展示）
  - 产物：01-需求(202行) / 02-设计(286行) / 03-代码索引(220行) / 04-测试(236行) / 05-完成(145行)
  - 代码：mdcounter.py(145行) + test_mdcounter.py(136行，14 个测试用例)
  - 质量：代码 < 200 行 ✅ / 测试覆盖 85% ✅ / 性能 < 100ms ✅
  
### 元发现（M1 · path-a 5 阶段首次完整 dogfooding）

**流程可行性**：
- 5 阶段全部跑通，无明显卡点
- 每阶段产物模板引导清晰，表格 / checklist 直接可用
- 02-设计.md 的"关键决策表格"（D1-D4）特别好用
- 05-完成.md 的"门控"段落让收尾有仪式感

**耗时估算**（实际开发 + 写文档）：
- 阶段 1（需求）：~30min
- 阶段 2（设计）：~40min
- 阶段 3（代码+索引）：~1h
- 阶段 4（测试）：~45min
- 阶段 5（完成）：~15min
- **总计**：~3h

**适用场景判断**：
- 简单项目（如 md-counter）略重（文档 1,089 行 > 代码 281 行）
- 但对复杂项目（需求不清 / 多人协作）价值会显著提升
- **结论**：path-a 流程验证可用 ✅

**模板改进点**：
- 03-代码索引.md 模板可以加"性能瓶颈"段（本次手动加的）
- 其余 4 个模板无需调整

---

## [1.0.19] - 2026-06-17

### Fixed (P2 · v1.0.17 加 path-a 第 5 阶段后忘记同步的"4 阶段"过时表述)

v1.0.17 加 `path-a/05-完成.md` 让 path-a 从 4 阶段变为 5 阶段，但**整个仓库其他地方的"4 阶段"引用没同步**。本次审计发现并修复 13 处：

- `templates/.claude/skills/harness-design/SKILL.md`：`阶段2/4` → `阶段2/5`
- `templates/.claude/skills/harness-req/SKILL.md`：`完整需求 4 阶段` → `5 阶段`
- `templates/templates/path-a/01-需求.md`：`阶段1/4` → `阶段1/5`（标题 + 末尾）
- `templates/templates/path-a/02-设计.md`：`阶段2/4` → `阶段2/5`（标题 + 末尾）
- `templates/templates/path-a/03-代码索引.md`：`阶段3/4` → `阶段3/5`（标题 + 末尾）
- `templates/templates/path-a/04-测试.md`：`阶段4/4` → `阶段4/5`（标题 + 末尾）
- `templates/templates/path-b/01-小需求.md`：`重新走4阶段` → `重新走5阶段`
- `templates/CLAUDE.md`：3 处（`工作流（4阶段...）` / 流程图 / `5阶段产物链路`）
- `CLAUDE.md`（仓根 dogfooding 版）：3 处
- stock_make_money 现场同步（CLAUDE.md + skills + path-a/b 模板）

### Verified

- stock validate.sh 跑一次全绿
- path-a 现在 5 处标题 + 5 处末尾全部 `X/5` 格式
- path-c 保持 `X/4`（4 阶段不变）
- path-b 保持 2 阶段（不变）

### 元发现

**M1 · 同根第 7 次（v1.0.17 → v1.0.19 之间漏的同步链）**：
- v1.0.17 加 05-完成.md → 心智模型只想着"加文件"
- 没想到"5 阶段"这个**事实**散布在 13 处文档/模板里
- 跟 v1.0.5/7/11/12 schema 漂移、v1.0.18 脚本漂移完全同根：**改一处忘了横向同步**

**M2 · validate.sh 抓不到这一类**：
- validate 检查文件存在 / 目录结构 / schema / 占位符 / hook if
- 但**抓不到"事实陈述与实际文件数不符"**——这是语义层面的漂移
- 加入 backlog："语义一致性检查"——v1.1+ 视情况

**M3 · "skill body 可能含过时表述"是新维度**：
- v1.0.7 修了 skill frontmatter，但 body 里的"4 阶段"留了 2 个月才发现
- 加入 backlog："skill body 也要纳入审计范围"

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
