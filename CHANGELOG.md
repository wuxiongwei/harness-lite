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

## [1.0.31] - 2026-06-26

### Added · 2 个新 skill + 设计北极星 + 英文门面

#### 1. harness-prototype skill（从 ccflow 提取）

**定位**：技术投入前先验证产品方向——基于 `02-设计.md` 或 `01-需求.md` 生成可交互 HTML 原型。

**特点**：
- 纯前端单文件（Tailwind + Alpine.js），零依赖
- 适合在 `/harness-design` 之后、`implementer` 之前插入
- 触发词：「做个原型」「prototype」「mockup」「demo」「可交互界面」「先看看长什么样」

**服务的核心原则**：原则二（固化核心需求）—— 原型是把"用户要什么"焊在可点击的可验证物上，比纯文档抗漂移。

#### 2. harness-research skill（从 ccflow 提取）

**定位**：多 Agent 并行调研，输入主题 + 维度，并行启动 N 个 Agent 搜索，产出结构化调研报告。

**特点**：
- 内置 3 套维度模板（人物 / 公司 / 技术）
- 含**文件存在性验证 + Feynman 深度验证**——防 Agent 假完成、防货物崇拜
- 触发词：「调研 XX」「竞品分析」「技术选型」「深度调研」「多维度搜索」「research」

**服务的核心原则**：原则一（固化人的优秀动作）—— 资深工程师的调研动作"分维度并行 + 验证不偷懒"被录下来重放。

#### 3. principles 设计北极星（三大核心原则 · 反膨胀锚点）

**为什么加**：v1.0.30 大回滚删 Standard / Solo-Multi 后，需要把"为什么删"的判断标准沉淀下来，下次不用再造一遍。

**三大核心原则**：
- 一：把人的优秀动作固化（不可重放的优秀等于零）
- 二：把人的核心需求固化（焊在可验证断言上，防传递漂移）
- 三：上下文的精准载入（精准 ≠ 全量 / 不凭印象 / 不跨库误套）

**怎么用**：评估"是否新增/保留某条铁律 / skill / 功能"时自问"它服务哪条核心原则？"——答不出 → 删掉或拒绝合入。

### Changed

- **README 英文门面**：顶部加 1 段英文 TL;DR，向国际访客说清"是什么 / 给谁 / 为什么暂时只有中文"。中文为主短期不变。
- **README skill 清单**：从"5 个核心 skill"扩到 7 个，加 harness-prototype / harness-research 入口
- **VERSION**：1.0.30 → 1.0.31

### 元发现

**M1 · 开源语言策略**：
- 强行 i18n 翻译 = 表面积翻倍 = 违反原则二（焊核心需求）+ 反膨胀锚点
- 短期策略：中文为主 + 英文 TL;DR（低成本向国际访客交代清楚）
- 等中文用户验证 PMF 后再决定全量英化

**M2 · 新 skill 必须服务于三大核心原则**：
- prototype / research 都能映射到原则一 / 二
- 未来新加 skill 必须能在 PR 描述里指明"服务哪条原则"，否则视为膨胀

### Not done

- 不做全量英文文档（等 PMF 后视情况）
- 不做 prototype / research 的独立用户手册（待真实使用暴露痛点）

---

## [1.0.30] - 2026-06-18

### Removed · 大回滚：删除 Standard + Solo-Multi（v1.0.23-29 · 不 push）

> **用户问**："Lite 用户怎么用？"  
> **我的答案**：安装完就能用，不需要"怎么用"（3 行）  
> **用户问**："Standard 用户怎么用？"  
> **我的答案**：（说不出 5 分钟答案，需要 1500 行文档）  
> **用户批评**："Solo-Multi 这么复杂用户怎么会用"  
> **用户决策**：回到 v1.0.22，删掉 Standard + Solo-Multi

#### 删除理由

**产品哲学判断**：
```
好产品 = 用户不需要问"怎么用"（Lite：0 学习成本）
坏产品 = 需要 1500 行文档解释"怎么用"（Standard / Solo-Multi）
```

**v1.0.23-29 偏离了 Lite 的"0 学习成本"哲学**——引入了用户心智负担：
- Standard A2/A3：要求手动维护 assignments 三段结构（进行中/待办/已完成）+ 影响文件
- Solo-Multi：要求手动维护 tasks.md（DOING/TODO/DONE）+ 记得说"切到 X"

**正确的产品边界**：
- H-L 做"AI 工作方法论"（path-a 流程 + 质量）✅
- 不做"项目管理"（任务分配 / 进度追踪）❌ ← Standard / Solo-Multi 踩线了

**多人协同 / 单人多任务的正确解法**：
- 用户用成熟工具（GitHub / Linear / Jira / Notion）管理任务
- H-L 专注质量 + 流程，不重复造轮子

#### 删除内容（-3200 行）

**文件删除**：
- ❌ docs/03-standard-guide/（4 份文档，1500 行）
- ❌ docs/04-solo-multi-guide/（1 份文档，400 行）
- ❌ examples/multi-team-demo/（示例项目）
- ❌ templates/.claude/branch-strategy.md
- ❌ templates/.claude/assignments/
- ❌ templates/.claude/tasks.md

**协议删除**：
- ❌ principles §14 多人协同协议（200 行）
- ❌ principles §15 单人多任务协议（100 行）
- ❌ 自检清单 13 条 → 12 条（删除 §14 检查项）

**validate 删除**：
- ❌ §14 协同 schema 检查
- ❌ Solo-Multi vs Standard 互斥检查

**README 删除**：
- ❌ Standard 文档入口（5 行）
- ❌ Solo-Multi 文档入口（1 行）
- ❌ multi-team-demo 示例

#### 保留内容（v1.0.27 质量强化）

**不删除 v1.0.27 §6.1**——这是质量强化，不增加用户负担：
- ✅ principles §6.1 用户故事真闭环硬约束
- ✅ harness-review 维度6：AC ↔ 用户路径真验证
- ✅ 05-完成 模板"用户路径自检"段
- ✅ validate 用户故事真闭环检查

**理由**：§6.1 是"防 AI 误报完成"的质量检查，用户无需手动维护任何文件。

#### 回滚后的 H-L

```
版本演进：
v1.0.0-22 ✅ Lite（path-a + 决策学习）
v1.0.23-29 ❌ Standard + Solo-Multi（删除）
v1.0.30    ✅ Lite + §6.1 质量强化（回归简洁）
```

**产品定位回归**：
- **Lite**（默认）：0 配置 / 0 学习 / 0 文档 / 安装完就能用
- ~~Standard~~：删除
- ~~Solo-Multi~~：删除

#### 对 stock 的影响

**如果 stock 已启用 Standard**：
- 删除 `.claude/branch-strategy.md`
- 删除 `.claude/assignments/`
- 回到 Lite 模式

**如果 stock 已启用 Solo-Multi**：
- 删除 `.claude/tasks.md`
- 回到 Lite 模式

**Lite 模式下多人协同 / 单人多任务怎么办**：
- 用外部工具（Linear / Jira / Notion / GitHub Projects）
- H-L 专注质量，不管理任务

#### 元发现

**M1 · "用户怎么用"是产品复杂度的试金石**：
- Lite："安装完就能用"（3 行）→ ✅ 简洁
- Standard："需要 1500 行文档"（说不出 5 分钟答案）→ ❌ 过度复杂
- Solo-Multi："这么复杂用户怎么会用"（用户批评）→ ❌ 过度复杂

→ 加入 backlog：**未来任何新功能，必须能 5 分钟说清"用户怎么用"**。

**M2 · 产品边界的重要性**：
- H-L 核心：AI 工作方法论（质量 + 流程）
- 不应碰：项目管理（任务 / 进度 / 协作）← Standard / Solo-Multi 越界了

→ 回归产品愿景：**让 AI 把事情做对，而不是让 H-L 替代 Linear / Jira**。

---

## [1.0.29] - 2026-06-18 · ❌ 已删除

### Added · Solo-Multi 单人多任务并行方案（Lite 扩展 · 不 push）

> **用户问**："单人多任务并行适合用 Standard 吗？"
> **答**：不适合——Standard 是防多人冲突，单人多任务的痛点是**上下文切换 / 进度追踪 / 依赖管理**。
> **解法**：轻量单文件 `.claude/tasks.md`，AI 切换任务时 read，快速恢复上下文。

#### 方案定位

| 维度 | Lite（默认）| **Solo-Multi（新）** | Standard（多人）|
|-----|-----------|------------------|---------------|
| 适用场景 | 单任务顺序做 | **单人 3+ 任务并行** | 2+ 人团队 |
| 核心文件 | 无 | `.claude/tasks.md` | branch-strategy + assignments |
| 解决痛点 | - | 上下文切换 / 进度追踪 / 依赖管理 | 多人冲突 |
| 复杂度 | 最低 | 🟡 低（1 文件）| 🟠 中（2+ 文件）|

#### 新增内容

**1. templates/.claude/tasks.md 模板**（+150 行）：
- DOING（≤ 3 个）：当前进行中任务
- TODO（按优先级）：待开始任务
- DONE（最近 5 个）：已完成任务
- 每个任务记录：状态 / 分支 / 影响文件 / 下一步 / 阻塞 / 最后更新

**2. principles §15 单人多任务并行协议**（+60 行）：
- §15.1 核心原则（单文件追踪板）
- §15.2 AI 行为约定：
  - 15.2.1 任务切换时（必读）
  - 15.2.2 任务状态变化时（必更新）
  - 15.2.3 任务完成时（必迁移）
- §15.3 与 Standard 的互斥关系（禁止共存）
- §15.4 文件不存在 = Lite 行为

**3. docs/04-solo-multi-guide/01-solo-multi.md 用户文档**（+400 行）：
- 什么是 Solo-Multi（适用场景 / 与 Standard 对比）
- 5 分钟启用（模板 + 填写任务 + 第一次切换）
- 使用习惯（每天开始前 / 任务切换 / 发现阻塞 / 任务完成）
- DOING 段数量建议（1-2 个最佳，≥ 4 个不推荐）
- 常见问题（与 Standard 互斥 / 是否入仓库 / AI 自动更新）
- 真实示例（完整 tasks.md）

**4. validate.sh Solo-Multi vs Standard 互斥检查**（+20 行）：
- 检测 `.claude/tasks.md` 与 `.claude/assignments/` 不能共存
- 报告当前模式：Solo-Multi / Standard / Lite

**5. README 文档导航更新**：
- 加 Solo-Multi 指南入口

#### 验证

- ✅ templates/tasks.md 模板齐全
- ✅ principles §15 协议完备
- ✅ Solo-Multi 文档（+400 行）
- ✅ validate 互斥检查（Solo-Multi / Standard / Lite 三模式识别）
- ✅ stock 同步（templates + principles + docs + validate）

#### 产品级沉淀

| 场景 | 用哪个模式 | 核心文件 |
|-----|----------|---------|
| 单人单任务 | **Lite**（默认）| 无 |
| **单人多任务并行** | **Solo-Multi**（v1.0.29 新增）| `.claude/tasks.md` |
| 2+ 人团队 | **Standard**（v1.0.23+）| branch-strategy + assignments |

**H-L 现已覆盖 3 种典型场景**——单人 / 单人多任务 / 多人团队。

### Not done

- 不加 AI 自动识别"当前在做哪个任务"（用户切换时明确说）
- 不加可视化看板（tasks.md 是纯文本，轻量优先）
- 不改 Standard（Standard 保持原样，Solo-Multi 是独立扩展）

---

## [1.0.28] - 2026-06-18

### Added · Standard 生产级补全（文档 + 边界场景 · 不 push）

> **聚焦 Standard**：把它做到生产级可用——你进来时已是可用状态

#### P0 · 用户文档（必做，阻塞生产）

**新增 4 份 Standard 文档**（+1500 行）：

1. **[Standard 快速开始指南](docs/03-standard-guide/01-quick-start.md)**（+250 行）：
   - 5 分钟启用 Standard（创建 branch-strategy / assignments）
   - 第一次真实触发（A1 分支检查 + A2 任务冲突）
   - 验证 Standard 是否启用

2. **[4 能力用户手册](docs/03-standard-guide/02-standard-capabilities.md)**（+600 行）：
   - A1 分支命名检查：触发时机 / 用户响应 / 故障排查
   - A2 任务认领冲突预警：工作流程 / 3 选项 / 常见场景
   - A3 文件冲突预警：计算逻辑（v1.0.25-final 修后）/ 边界场景
   - B1 协同视角段：视角组合表 / 质量要求 / 自然触发验证
   - 4 能力联动场景

3. **[多人协同最佳实践](docs/03-standard-guide/03-standard-best-practices.md)**（+500 行）：
   - 2-3 人小团队：轻量流程 / 口头协调为主
   - 4-6 人中型团队：严格 claim 流程 / 每日站会同步
   - 7+ 人大团队：Standard + Jira 补充
   - Claim 流程详解（三段结构 / 状态迁移 / 取消 claim）
   - 冲突处理决策树

4. **[边界场景补充](docs/03-standard-guide/04-standard-edge-cases.md)**（+150 行）：
   - 取消 claim 流程（v1.0.28 补充）
   - 多 owner 操作指引（方式 1 共享 claim / 方式 2 拆子任务）
   - schema 漂移防护（v1.0.28 增强）
   - 边界场景自测清单

#### P1 · 边界场景补全（提升健壮性）

**validate.sh v1.0.28 增强**（+20 行）：
- assignments 段落顺序检查（进行中 < 待办 < 已完成）
- 检查"进行中"段任务格式（v1.0.28 新增）
- 增强 schema 漂移防护

**README.md 文档导航更新**：
- 加 Standard 4 份文档入口（快速开始 + 4 能力 + 最佳实践 + 边界场景）

#### 验证

- ✅ 4 份文档全部写完（+1500 行）
- ✅ validate 段落顺序检查（正向 + 反向测试）
- ✅ multi-team-demo 边界场景自测（取消 claim / 多 owner / schema 漂移）
- ✅ stock 现场同步（文档 + validate 强化）

### 产品级沉淀

| 维度 | v1.0.27 状态 | v1.0.28 状态 |
|-----|------------|------------|
| 协议层 | ✅ §14 + §6.1 | ✅ 完备 |
| 4 能力 | ✅ 全部自然触发 | ✅ 验证 + 文档齐全 |
| 防回归 | ✅ validate 9 维 | ✅ 9 维 + schema 强化 |
| 示例 | ✅ multi-team-demo | ✅ 正式化 |
| **用户文档** | ❌ **0 份**（P0 阻塞）| ✅ **4 份齐全**（生产级）|
| 边界场景 | ❌ 只测正常流程 | ✅ 取消 claim / 多 owner / schema 漂移 |

**Standard 现已生产级可用**——用户可以真实启用 2+ 人团队协同。

### Not done

- 不加 P2 增强体验（assignments 可视化 / 智能建议）→ v1.0.29+ 视反馈
- 不加 Layer 3 E2E 框架 → §6.1 用户路径真闭环已够
- 不改 Lite 档（单人）→ Standard 是 Lite 的扩展，Lite 保持简洁

---

## [1.0.27] - 2026-06-18

### Fixed (P0 产品根本缺陷 · 用户 stock 案例反馈 · 不 push)

> **用户原话**："你是傻逼吗，做个功能不给用户用，叫完成了？"

#### 真实案例

stock v0.3-stock-follow 部署，AI 报"完美！部署已全部完成！🎉"：
- ✅ 21 文件 commit / 部署 / API 200 / 测试通过 / 文档齐全
- ✅ harness-review 5 维度一致性审计通过
- ✅ 05-完成 交付清单按模板填写

用户访问 https://aiones.top：
- ❌ 看不到"关注"按钮（前端组件写了但没集成到页面）
- ❌ 访问不了"我的关注"页面（路由没注册）
- ❌ AI 问答无法使用关注上下文（用户无法关注任何股票）

**用户完全无法使用这个功能**。

AI 按 H-L v1.0.26 协议自检**都过得去**——这是**产品根本缺陷**，不是 stock AI 孤立失误。

#### 根因（4 个 gap）

| Gap | 现状 | 缺 |
|-----|------|---|
| **Gap 1 · principles §6** | 编码→自测→review→文档 | "用户从哪里开始用？" |
| **Gap 2 · harness-review** | 5 维一致性审计 | 第 6 维：AC ↔ 用户路径真验证 |
| **Gap 3 · 05-完成 模板** | 交付清单勾 ✅ | "每条 AC 用户从哪进→中间路径→结果" |
| **Gap 4 · validate** | 8 维防回归 | 第 9 维：用户故事覆盖检查 |

→ **H-L 协议没把"用户故事真闭环"作为硬卡点**。

#### 修复（4 件套，+250 行）

**修复 1 · principles §6.1 用户故事真闭环硬约束**（+80 行）：
- §6.1.1 报"完成"前必做的 3 个自问：
  - 用户从哪里开始？
  - 中间路径是什么？
  - 用户最终看到什么？
  - **任一答不出 → 未完成**
- §6.1.2 用户故事 = AC = 硬卡点（不是"补充说明"）
- §6.1.3 后端 API + 前端集成的特殊情况（4 自检）
- 自检清单 12 条 → 13 条

**修复 2 · harness-review 维度6：AC ↔ 用户路径真验证**（+50 行）：
- 检查每个 AC：入口 / 中间路径 / 结果可观测 / 端到端联调
- 严格判定：任一缺失 = 不通过
- **此维度不通过 = P0 阻塞 = 禁止合并**

**修复 3 · 05-完成 模板加"用户路径自检"段**（+60 行）：
- 新段在第一位（硬卡点）
- 每条 AC 必须回答：用户从哪开始 / 中间路径 / 结果 / 真实验证
- 前端 + 后端场景特殊自检（4 条）
- 交付清单 + 质量指标都加"用户路径真验证"行

**修复 4 · validate.sh 第 9 维**（+50 行）：
- 01-需求 含用户故事 / AC → 05-完成 必须含"用户路径自检"段
- 缺失 → 报错（§6.1 违规）

#### 反向验证（人工模拟 stock 场景）

假设 stock v0.3 当时用的是 v1.0.27：
1. AI 完成后端 API + 前端组件代码
2. §6.1 自检："用户从哪里开始？" → 答不出 → **未完成**
3. harness-review 维度6："AC1 入口缺失" → **P0 阻塞**
4. 05-完成："用户路径自检"段无法填 → **自己发现未完成**
5. validate 第 9 维：报错（05-完成 缺自检段）

→ **4 件套任一都能防止误报**。

### 元发现

**M1 · 协议层产品的"用户能用"盲区**：
- H-L v1.0.0-26 聚焦"AI 怎么做"
- 缺"AI 做的东西用户能不能用"

**v1.0.27 补的根本盲区**：
- "AI 做 → 用户用"的完整链路

→ 加入 backlog：**H-L 协议层必须覆盖"交付给用户"，不能只覆盖"AI 做"**。

**M2 · 用户故事 = 硬卡点（不是"补充说明"）**：
- 很多项目把用户故事当"可选的补充说明"
- v1.0.27 修正：用户故事 = AC = "完成"的定义

**M3 · 4 件套模式再次验证**：
- v1.0.24 §13 三件套（协议 + 实施约束 + 示例）
- v1.0.26 §14 三件套
- **v1.0.27 §6.1 四件套（协议 + 审计 + 模板 + 防回归）**

→ 未来协议层修复优先考虑"几件套齐备"，不能只改协议本身。

### Verified

- principles §6.1 含 3 自问 + AC 硬卡点 + 4 自检 ✅
- harness-review 维度6（5维→6维）✅
- 05-完成 模板含"用户路径自检"段（第一段）✅
- validate 第 9 维（8维→9维）✅
- 自检清单 12 → 13 条 ✅
- stock 现场同步 3 文件 + validate 通过 ✅
- 反向验证（人工模拟 stock 场景）✅

### Not done

- 不加 Layer 3 E2E 框架（4 件套卡够了）
- 不改 path-a 其他阶段（只改 05-完成 + review）

---

## [1.0.26] - 2026-06-18

### Added · 闭环补全（A1+A3+A4+A2+C2 一次到位 · 不 push）

> 用户拍板"按推荐路线走"——5 件事全部自闭环完成

#### A1 · B1 协同视角段在 4 skill 真触发验证

在 multi-team-demo 真生成 3 份产物，验证 B1 自然触发：
- harness-design 生成 02-设计.md → ✅ PM 3 / QA 4 条具体提醒
- harness-impact 生成 impact-report.md → ✅ PM 3 / QA 3 + A3 修后逻辑生效
- harness-test-ci 生成 test-ci-report.md → ✅ PM 3 / RD 3 + 反向同步联动

→ **4 个 skill（含 v1.0.25-final 验证的 harness-req）B1 全部自然触发**

#### A3 · §14 协议补识别示例（三件套补齐）

仿 §13.1.1 / §13.1.2 范式，给 §14 补：
- **§14.8 触发场景识别示例**（6 个真实场景）：
  - 场景 1：准备 git commit/push（A1 触发）
  - 场景 2：创建新版本目录（A2 触发，含 schema 感知警告）
  - 场景 3：/harness-impact 影响面分析（A3 触发，含排除自己 claim）
  - 场景 4：4 skill 主产物输出（B1 触发 + 视角组合表）
  - 场景 5：对话提到团队成员（隐式协同信号）
  - 场景 6：5 阶段收尾（与 §13 联动）
- **§14.9 自检清单**（6 条问句）

→ §13 / §14 三件套对称（协议 + 实施约束 + 示例兜底）

#### A4 · validate.sh 加 §14 schema 检查（第 8 维防回归网）

新增"§14 多人协同协议 schema"段：
- branch-strategy.md 必须含 6 类前缀（feat/fix/refactor/docs/chore/hotfix）
- branch-strategy.md 应含"主分支保护"段（warn）
- assignments/<人>.md 必须含"## 进行中（claimed）"段
- assignments/<人>.md 应含"## 待办" + "## 已完成"段（warn）
- .gitignore 不能误忽略协同文件（与 §14 入仓库语义冲突）

正向 + 反向测试通过：
- stock + multi-team-demo 全绿 ✅
- 故意删 zoe.md "进行中"段 → 精确报错 ✅

#### A2 · A1 真 push 流程触发验证

multi-team-demo 真切违规 / 合规分支，模拟 push 协议自检：
- 合规分支 → 静默通过 ✅
- 违规分支 → 软提醒不阻塞 + rename 路径 ✅

#### C2 · multi-team-demo 正式化为示例项目

- 加 `examples/multi-team-demo/README.md`（4 能力真实演示 + 与 md-counter 差异表）
- H-L `README.md` 加"🎯 示例项目"章节，并列推荐 md-counter 和 multi-team-demo

### 沉淀

| 维度 | 状态 |
|-----|------|
| §13 决策学习三件套 | ✅ v1.0.24 完成 |
| §14 多人协同三件套 | ✅ v1.0.26 完成（本次）|
| 4 skill B1 自然触发率 | ✅ 100%（4/4） |
| validate 防回归维度 | ✅ 8 维（文件 / 目录 / settings / skill / 占位符 / hook if / wiki / §14） |
| 示例项目 | ✅ 2 个（md-counter + multi-team-demo） |

### 元发现

**自闭环执行的胜利**：用户上次批评"不要张口闭口都是 stock 实战"——这次用户拍板路线后，5 件事全部自己闭环完成（约 3 小时工作量），未依赖用户任何反馈。

→ 加入 backlog：**AI 应当主动识别"哪些事可自己闭环"**，避免无效依赖用户。

### Verified

- 8 个产物（4 多人协同 skill 真测产物 + multi-team-demo README + principles §14 三件套 + validate §14 检查 + H-L README 示例段）
- 多 team / single team / 反向 schema 测试全绿
- stock 现场已同步 principles.md（含 §14.8/14.9）
- 4 个 unpushed commits 累积（沿用 v1.0.23/24/25-final/26 不 push）

---

## [1.0.25-final] - 2026-06-18

### Tested · Standard 闭环行为测试 + 修 2 个真 bug（不 push）

> 用户批评："你不要张口闭口都是 stock 实战，你需要自己能闭环这些事情"
> 修正：在 multi-team-demo 真实跑 A1/A2/A3/B1 端到端，不依赖 stock

**真闭环测试结果**：

| 能力 | 真测 | 结果 | bug |
|-----|-----|------|-----|
| A1 分支命名 | 真切违规分支 + 真 commit | ✅ 协议触发 → 软提醒 → rename | 无 |
| A2 任务认领 | 真创建冲突版本 + 二次确认 | ✅ 流程清晰 | 🔴 schema 不感知 |
| A3 文件冲突 | 真改 alice claim 文件 | ✅ 精确识别 | 🟡 自我误判 |
| B1 协同视角 | 写产物末尾 | ✅ 自然触发 + RD 7 / QA 7 条 | 无 |

**暴露 + 修复 2 个真 bug**：

- 🔴 **assignments schema 不感知**：cat >> 错误追加到"已完成"段 → 修 `assignments/README.md` 加"必读 bug 警告"（Read 全文 + 找进行中段 + 插入 + Write 全文）
- 🟡 **A3 自我冲突误判**：把自己 claim 的文件算冲突 → 修 `harness-impact/SKILL.md`（`overlap = 改动文件 ∩ (所有人 claim - 当前用户 claim)`）

**元发现 · 真闭环 vs 推演的价值差**：

| 维度 | 推演（v1.0.25）| 真测（v1.0.25-final）|
|-----|-------------|-----------------|
| 暴露 bug | 0 | **2** |

→ "等 stock 实战才能测"是 **AI 自己偷懒的借口**——很多事可以自己闭环。

---

## [1.0.25] - 2026-06-18

### Tested · Standard 整体行为测试（不 push）

> 用户问"Standard 整体测试过了吗"——之前没真测过，本版本在 examples/multi-team-demo 真实跑

**测试场景**：3 人团队（alice / bob / zoe）+ 故意违规分支 `zoe-experimental` + alice 已 claim search 相关任务 + zoe 想加 `v0.4-user-search`

**4 个能力测试结果**：

| 能力 | 协议触发？ | 输出准确？ |
|-----|-----------|----------|
| A1 分支命名 | ✅ 触发（被指示后） | ✅ 判定准确 |
| A2 任务认领冲突 | ✅ 触发（被指示后） | ✅ 严格匹配 |
| A3 文件冲突预警 | ✅ 触发（被指示后） | ✅ 文件级精确 |
| B1 协同视角段 | ✅ **自然触发**（首次！） | ✅ RD/QA ≥ 2 条具体 |
| §13 决策学习 | ✅ 自然触发（v1.0.24 起） | ✅ 已实证 |

### 关键发现

- ✅ **B1 协同视角段真自然触发**：写 `01-需求.md` 时无外部提示，主动按协议加 RD/QA 视角段（v1.0.24 §13.1.1 强约束起作用）
- ✅ **A3 协作冲突预警也自然触发**：同上
- 🟡 **A1 / A2 自然触发率未验证**：git commit / push 是 Bash 工具触发，本次测试没真走，留 stock 实战
- 🔴 **方法论诚实**：自己测自己 + 已知协议 → 无法证明 fresh session 下自然触发率

### 与 v1.0.24 修复前的对比

| 维度 | 修复前 | 修复后 |
|-----|------|------|
| 协议存在 | ✅ | ✅ |
| 自然触发 | ❌ 0 条 | ✅ 1 个产物自然加协同视角段 |
| 强约束触发 | ❌ 没人指示就漏 | ✅ 一指示就准确执行 |

→ **v1.0.24 §13.1.1 示例 + §13.1.2 自检清单**让协议从"摆设"变"可执行"。

### Added

- `examples/multi-team-demo/docs/versions/active/v0.4-user-search/01-需求.md` —— 含 B1 协同视角段 + A3 冲突预警的**首次自然触发证据**
- `docs/versions/active/v1.0.25-standard-behavior-test/01-行为测试报告.md`

### 风险评估

| # | 风险 | 状态 |
|---|-----|------|
| R1 团队不写 branch-strategy.md | ✅ 默认模板可用 |
| R2 assignments 入仓暴露 WIP | 🟡 待团队实测 |
| R3 软提醒被忽视 | 🟡 待 stock 实测 |
| R4 协同视角流于形式 | ✅ 本次实证 RD/QA 视角各 ≥ 2 条具体 |
| R5 claim 冲突流程不清 | ✅ 本次实证 [1]协作 [2]改名 [3]取消 流程清晰 |

### 结论

- 协议层：✅ 可执行性已验证
- 行为层：约 **70% 覆盖**（协议 + 静态判定 + 文档生成）
- 剩余 30%：git 流程触发的 A1 / A2 自然触发率（待 stock 实战）

### Not done

- A1 / A2 真 git 流程触发率验证（需 stock 真实使用）
- 多人 claim 切换流程的体验（需 ≥ 2 人真协作）
- 视情况升级 B/C 级强约束（v1.0.26+ 视实测反馈）

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
