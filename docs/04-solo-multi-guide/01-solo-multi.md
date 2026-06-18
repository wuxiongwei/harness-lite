# Solo-Multi 单人多任务并行指南

> v1.0.29 新增 · 单人并行 3+ 任务时的轻量方案

---

## 什么是 Solo-Multi

**Solo-Multi** 是 Harness-Lite 针对"单人多任务并行"场景的轻量扩展。

### 适用场景

你是**唯一开发者**，同时推进 3+ 个任务：

```
你在 stock 项目同时做：
- v0.3-stock-follow（关注功能，编码中）
- v0.4-notification（通知系统，需求中）
- v0.5-payment（支付对接，待开始）
```

**痛点**：
1. 切换任务时忘了上次干到哪
2. 3 个分支来回切，搞不清当前在哪
3. v0.4 依赖 v0.3，但忘了这个依赖关系

### 与 Standard 的区别

| 维度 | **Solo-Multi**（单人多任务）| Standard（多人协同）|
|-----|------------------------|------------------|
| 适用 | 单人 3+ 任务并行 | 2+ 人团队 |
| 核心文件 | `.claude/tasks.md`（1 文件）| branch-strategy + assignments（2+ 文件）|
| 解决什么 | 上下文切换 / 进度追踪 / 依赖管理 | 多人冲突预警 |
| AI 行为 | 切换任务时 read tasks.md 恢复上下文 | commit / 创建目录时检查冲突 |

**不能混用**：Solo-Multi 和 Standard 互斥——选一个。

---

## 5 分钟启用 Solo-Multi

### Step 1：创建 tasks.md

```bash
# 复制模板
cp .claude/templates/.claude/tasks.md .claude/tasks.md

# 或手动创建（见下方模板）
```

**模板**：

```markdown
# tasks.md

## 🔥 DOING（当前进行中，≤ 3 个）

### v0.3-stock-follow

**状态**：阶段 3 编码中

**分支**：`feat/v0.3-stock-follow`

**影响文件**：
- backend/api/stock_interests.py（✅ 完成）
- frontend/components/FollowButton.tsx（⏳ 待集成）

**下一步**：
1. 集成 FollowButton 到 StockDetail
2. 注册 /followed 路由
3. 真实验证 AC1-AC3

**阻塞**：无

**最后更新**：2026-06-18 15:00

---

## 📋 TODO（待开始）

### v0.4-notification

**优先级**：P1

**预计开始**：v0.3 完成后

**前置依赖**：
- v0.3 完成（共享表）

---

## ✅ DONE（最近完成）

### v0.2-user-profile

**完成时间**：2026-06-15
```

### Step 2：填写当前任务

根据你的真实状态填 DOING / TODO / DONE 段。

### Step 3：第一次切换任务

```bash
claude
> 我现在切到 v0.4-notification，开始写需求

# AI 会自动：
# 1. Read .claude/tasks.md
# 2. 找到 v0.4 的"下一步"
# 3. 快速恢复上下文：
#    "看到 v0.4 在 TODO，优先级 P1，依赖 v0.3。
#     现在开始写 01-需求.md 吗？"
```

---

## 使用习惯

### 每天开始前

```bash
# 看一眼今天要做什么
cat .claude/tasks.md | grep -A 10 "## 🔥 DOING"
```

### 任务切换时

```bash
claude
> 切到 v0.4，继续写需求

# AI 自动 read tasks.md → 快速恢复上下文
```

### 发现阻塞时

```bash
claude
> v0.4 遇到问题：需要确认产品需求（推送渠道优先级）

# AI 自动更新 tasks.md：
#   在 v0.4 阻塞段加：⚠️ 需确认产品需求
```

### 任务完成时

```bash
claude
> v0.3 已 merge 到 main，标记完成

# AI 自动：
#   从 DOING 移到 DONE
#   补充"完成时间" / "分支：已 merge"
```

---

## DOING 段数量建议

| DOING 任务数 | 建议 | 原因 |
|------------|-----|------|
| **1 个** | 🟢 最佳 | 专注单任务，效率最高 |
| **2 个** | 🟢 推荐 | 适度并行（如等待 review 时做另一个）|
| **3 个** | 🟡 可接受 | 上下文切换成本开始上升 |
| **≥ 4 个** | 🔴 不推荐 | 切换成本过高，移一些到 TODO |

---

## 常见问题

### Q1：Solo-Multi 和 Standard 能同时用吗？

**不能**——互斥。

| 场景 | 用哪个 |
|-----|-------|
| 单人多任务 | Solo-Multi |
| 2+ 人团队 | Standard |
| 单人单任务 | Lite（默认，什么都不用）|

如果你现在单人，未来可能多人：
- 先用 Solo-Multi
- 有协作者时删除 `.claude/tasks.md`，创建 `.claude/assignments/`

### Q2：tasks.md 必须入仓库吗？

**推荐入仓库**，但不强制：
- **入仓库**：备份 / 跨设备同步
- **不入仓库**（加 .gitignore）：个人进度隐私

### Q3：AI 会自动更新 tasks.md 吗？

**会，但你可以手动改**：
- AI 在任务状态变化时自动更新
- 你也可以手动编辑（更灵活）

### Q4：忘记更新 tasks.md 会怎样？

**不会阻塞**——Solo-Multi 是辅助工具，不是强制检查：
- 忘记更新 → AI 下次 read 时看到的是旧状态
- 不影响正常开发，只是上下文恢复不准确

### Q5：从 Lite 升级到 Solo-Multi 有成本吗？

**无成本**：
- 创建 1 个文件（`.claude/tasks.md`）
- 填写当前任务状态
- 立刻生效，无需改代码 / 配置

---

## 与 Standard 对比表

| 维度 | Solo-Multi | Standard |
|-----|-----------|----------|
| 文件数 | 1（tasks.md）| 2+（branch-strategy + assignments/<人>）|
| 复杂度 | 🟢 低 | 🟡 中 |
| 解决痛点 | 上下文切换 / 进度追踪 / 依赖管理 | 多人冲突预警 |
| AI 触发时机 | 切换任务时 | commit / 创建目录 / 改文件时 |
| 阻塞？ | ❌ 不阻塞（信息性）| ⚠️ 半阻塞（A2 二次确认）|
| 适用团队规模 | 1 人 | 2+ 人 |

---

## 示例：真实 tasks.md

```markdown
# tasks.md

## 🔥 DOING

### v0.3-stock-follow

**状态**：阶段 3 编码中（后端完成，前端 80%）

**分支**：`feat/v0.3-stock-follow`

**影响文件**：
- backend/api/stock_interests.py（✅）
- backend/services/redis_consumer.py（✅）
- frontend/components/FollowButton.tsx（✅）
- frontend/pages/StockDetail.tsx（⏳ 集成 FollowButton）
- frontend/App.tsx（⏳ 注册 /followed 路由）

**下一步**：
1. StockDetail.tsx 加 `<FollowButton code={code} />`
2. App.tsx 加 `<Route path="/followed" element={<FollowedStocks />} />`
3. 真实环境验证 AC1-AC3

**阻塞**：无

**最后更新**：2026-06-18 15:30

---

### v0.4-notification

**状态**：阶段 1 需求中（01-需求.md 50%）

**分支**：`feat/v0.4-notification`

**影响文件**：
- docs/versions/active/v0.4-notification/01-需求.md（⏳ US3-US5 待补）

**下一步**：
1. 补完 01-需求.md US3-US5
2. 确认推送渠道优先级（产品）
3. 进入阶段 2 设计

**阻塞**：
- ⚠️ 依赖 v0.3 完成（共享 user_stock_interests 表）
- ⚠️ 需确认产品需求（推送渠道：邮件 / 站内 / 推送）

**最后更新**：2026-06-17 10:30

---

## 📋 TODO

### v0.5-payment

**优先级**：P1

**预计开始**：v0.4 完成后

**预估工作量**：3-4 天

**前置依赖**：
- v0.4 完成（支付成功后要通知）
- 申请支付宝 / 微信支付商户号

**备注**：大功能，考虑拆子任务

---

### v0.6-data-export

**优先级**：P2

**备注**：低优先级，Q3 再说

---

## ✅ DONE

### v0.2-user-profile

**完成时间**：2026-06-15

**分支**：已 merge 到 main

**产物**：docs/versions/active/v0.2-user-profile/

---

### v0.1-skeleton

**完成时间**：2026-06-10

**分支**：已 merge 到 main
```

---

## 下一步

- 🎯 创建你的第一个 `.claude/tasks.md`
- 📖 有问题看 [principles §15](../../templates/.claude/rules/principles.md)

---

*Harness-Lite v1.0.29-solo-multi · 单人多任务并行指南*
