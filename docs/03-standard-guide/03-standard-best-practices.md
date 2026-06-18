# Standard 多人协同最佳实践

> 2-3 人小团队 vs 5+ 人大团队的不同用法 + claim 流程 + 冲突处理

---

## 团队规模与 Standard 用法

| 团队规模 | 推荐用法 | assignments 管理 | 典型痛点 |
|---------|---------|-----------------|---------|
| **1 人** | ❌ 不推荐 Standard（用 Lite）| - | 协同机制是冗余 |
| **2-3 人** | ✅ 轻量 Standard | 口头协调为主 + assignments 辅助 | 偶尔撞车 |
| **4-6 人** | ✅ 标准 Standard | assignments 必须 + 每日同步 | 频繁撞车 + claim 过期 |
| **7+ 人** | ⚠️ Standard + 补充工具 | assignments + Jira/Linear | Standard 不够（需外部看板）|

---

## 2-3 人小团队最佳实践

### 典型场景

你 + 1-2 个协作者，项目处于快速迭代期。

### 推荐配置

**最小配置**：
```bash
# 只创建 branch-strategy.md（A1）+ assignments（A2/A3）
.claude/branch-strategy.md
.claude/assignments/alice.md
.claude/assignments/bob.md
.claude/assignments/README.md
```

**B1 协同视角段**：默认开启（无需配置）。

### Claim 流程

**轻量流程**（适合 2-3 人）：

```
1. 口头/群聊："我做 v0.5-payment"
2. 自己更新 assignments：
   echo "### v0.5-payment
   - claim 时间：$(date +%Y-%m-%d)
   - 状态：阶段 1 需求中
   - 影响文件：
     - src/payment/alipay.py
   - 协作者：—" >> .claude/assignments/alice.md

3. git add + commit
4. 开始干活（AI 会自动检查冲突）
```

**什么时候不需要 claim**：
- 纯文档修改（README / docs/）
- 紧急 hotfix（< 1 小时完成）
- 独立新模块（100% 不会冲突）

### 冲突处理

**场景 1 · 同一文件不同部分**：
```
alice: search.py 加 basic_search()
bob: search.py 加 user_search()

处理：
1. A3 会标 ⚠️
2. 口头协调："alice 你先 merge，我 rebase"
3. alice merge 完 → bob git rebase main
```

**场景 2 · 功能重叠发现晚了**：
```
alice 做到一半：v0.3-login（OAuth）
bob 也做到一半：v0.4-login-sso（SSO）
→ 发现重叠

处理（3 种）：
[1] 并入：bob 放弃 v0.4，加入 alice v0.3（多 owner）
[2] 拆分：alice 做 OAuth，bob 改为 v0.4-sso-only
[3] 顺序：bob 暂停，等 alice v0.3 merge 后继续 v0.4
```

### 避坑指南

| 坑 | 后果 | 避免方法 |
|---|------|---------|
| 不更新 assignments | A2/A3 失效 | 养成习惯：claim 任务立刻更新 |
| claim 后忘记推 | 别人看不到 | claim 后立刻 push（不等代码写完）|
| assignments 写错段落 | validate 报错 | 用模板（三段结构：进行中/待办/已完成）|
| 分支名随意 | A1 频繁提醒 | 统一用 feat/fix 前缀 |

---

## 4-6 人中型团队最佳实践

### 典型场景

多人并行开发，代码库复杂，冲突频繁。

### 推荐配置

**标准配置**：
```bash
.claude/branch-strategy.md           # 必须（A1）
.claude/assignments/
  ├── alice.md                       # 每人一个
  ├── bob.md
  ├── charlie.md
  ├── david.md
  └── README.md

# 可选：每日同步脚本
scripts/sync-assignments.sh          # 每日拉最新 assignments
```

### Claim 流程

**严格流程**（适合 4-6 人）：

```
1. 立项：先在 assignments "待办"段占位
   ### v0.8-notification（待办）
   - 预计开始：2026-06-20
   - 负责人：alice（暂定）

2. 开始前：移到"进行中" + 更新详情
   ### v0.8-notification（进行中）
   - claim 时间：2026-06-20 09:00
   - 状态：阶段 1 需求中
   - 影响文件：
     - src/notification/...
   - 协作者：bob（UI 部分）

3. 每日站会：口头同步 + 更新 assignments 状态
4. 完成后：移到"已完成" + 写完成时间
```

### 冲突处理

**高频场景 · 核心文件多人改**：

```
场景：src/config.py 被 3 人同时 claim 改
alice：加 notification 配置
bob：加 cache 配置
charlie：重构配置结构

处理：
1. A3 会标 3 个 ⚠️
2. 开会：决定顺序（charlie 重构最优先）
3. alice/bob 暂停 → charlie 完成 merge → alice/bob rebase
```

**多 owner 场景**：

```
v0.10-payment-integration（大功能）
- 协作者：alice（支付宝）+ bob（微信）+ charlie（银联）

claim 方式：
1. alice 先 claim v0.10
2. bob/charlie 各自在 alice assignments 加"协作者"
3. 或各自 claim v0.10-alipay / v0.10-wechat（拆子任务）
```

### 避坑指南

| 坑 | 后果 | 避免方法 |
|---|------|---------|
| assignments 状态过期 | A2/A3 误报或漏报 | 每日站会同步状态 |
| claim 时不写影响文件 | A3 失效 | 模板强制要求（validate 检查）|
| 分支太长寿命 | merge 冲突爆炸 | 强制 3 天内 merge（branch-strategy 规定）|
| 多人改同一函数 | git 冲突 + 逻辑冲突 | 函数级拆分 + 提前沟通 |

---

## 7+ 人大团队补充建议

### Standard 不够的地方

| Standard 能做 | Standard 不能做 | 补充工具 |
|-------------|---------------|---------|
| 文件级冲突预警 | 函数级冲突预警 | Code review |
| 任务 claim 记录 | 任务依赖 / 时间线 | Jira / Linear |
| 协同视角段 | 跨团队协作 | 设计评审会 |
| 分支命名检查 | CI/CD 流程 | GitHub Actions |

### 推荐组合

```
Standard（基础协同）
  + Jira（任务管理 + 依赖图）
  + Code review（函数级冲突 + 质量）
  + 设计评审会（跨团队对齐）
```

### 示例工作流

```
1. Jira 立 Epic：v0.15-order-system
2. 拆 Story：v0.15-order-create / v0.15-order-list / ...
3. alice claim v0.15-order-create：
   - Jira 状态改 "In Progress"
   - 更新 .claude/assignments/alice.md
4. 开发中：Standard A1/A2/A3/B1 自动协同
5. PR review：Code review 补函数级检查
6. Merge 后：Jira 改 "Done" + assignments 移到"已完成"
```

---

## Claim 流程详解

### assignments 三段结构

```markdown
# 任务认领（alice）

## 进行中（claimed）

### v0.8-notification
- claim 时间：2026-06-20 09:00
- 状态：阶段 3 编码中
- 影响文件：
  - src/notification/push.py
  - src/notification/email.py
- 协作者：bob（前端对接）
- 备注：依赖 v0.7-user-service 完成

## 待办（pending）

### v0.9-report
- 预计开始：2026-06-25
- 负责人：alice（暂定）

## 已完成（done）

### v0.7-user-service
- 完成时间：2026-06-18
- 协作者：—
```

### 状态迁移

```
待办（pending）
    ↓ claim
进行中（claimed）
    ↓ merge
已完成（done）
```

### 取消 claim 流程（v1.0.28+ 补充）

```bash
# 场景：alice claim 了 v0.8，干到一半发现做不了
# 操作：
1. 从"进行中"段删除 v0.8
2. （可选）移到"待办"段 + 加备注"alice 尝试过，遇到 XX 问题"
3. git commit -m "unclaim: v0.8-notification（遇到依赖问题）"
4. 通知团队（群聊 / 站会）
```

---

## 冲突处理决策树

```
发现冲突（A2 或 A3 触发）
    ↓
问：功能是否重叠？
├─ 是 → 问：能否拆分？
│        ├─ 能 → [拆分]：各做各的部分
│        └─ 不能 → [顺序]：一个人先做，另一个等
└─ 否 → 问：文件是否重叠？
         ├─ 是 → 问：改的是同一部分吗？
         │        ├─ 是 → [顺序] 或 [并入多 owner]
         │        └─ 否 → [并行]：约定一个先 merge，另一个 rebase
         └─ 否 → [无冲突]：继续
```

---

## 常见问题

### Q1：assignments 必须每次都更新吗？

**是的**——Standard A2/A3 依赖 assignments 实时性。过期的 assignments = 失效的冲突预警。

**建议**：
- 小团队（2-3 人）：claim 时更新 + 完成时更新
- 中团队（4-6 人）：每日站会同步状态

### Q2：claim 后能改影响文件吗？

可以，但**必须更新 assignments**：

```markdown
### v0.8-notification
- 影响文件：
  - src/notification/push.py
  - src/notification/email.py
  - src/notification/sms.py  # 新增（2026-06-21）
```

### Q3：多 owner 任务怎么 claim？

**方式 1**（推荐）：
```markdown
# alice.md
### v0.10-payment
- 协作者：bob, charlie

# bob.md
### v0.10-payment
- 协作者：alice, charlie

# charlie.md
### v0.10-payment
- 协作者：alice, bob
```

**方式 2**（拆子任务）：
```markdown
# alice.md
### v0.10-payment-alipay

# bob.md
### v0.10-payment-wechat
```

### Q4：branch-strategy 能自定义吗？

可以，但**必须保留 6 类前缀**（feat/fix/refactor/docs/chore/hotfix），否则 A1 失效。

自定义示例：
```markdown
## 命名规范

feat/<jira-id>-<short-name>    # 如 feat/PROJ-123-user-login
fix/<jira-id>-<short-name>
```

---

## 下一步

- 🎯 参考 [examples/multi-team-demo](../../../examples/multi-team-demo)（3 人团队真实示例）
- 📖 如遇问题，查 [4 能力用户手册 § 故障排查](02-standard-capabilities.md)

---

*Harness-Lite v1.0.28-standard-production · 多人协同最佳实践*
