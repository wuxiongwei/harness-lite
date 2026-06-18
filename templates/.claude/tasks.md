# tasks.md

> **单人多任务并行追踪板**（Solo-Multi 模式 · v1.0.29）
> 
> 本文件记录你当前并行的多个任务：状态 / 分支 / 阻塞 / 下一步。
> AI 在切换任务时会 read 此文件，帮你快速恢复上下文。

---

## 🔥 DOING（当前进行中，≤ 3 个）

### v0.3-stock-follow

**状态**：阶段 3 编码中（后端完成，前端集成待做）

**分支**：`feat/v0.3-stock-follow`

**影响文件**：
- backend/api/stock_interests.py（✅ 完成）
- frontend/components/FollowButton.tsx（⏳ 待集成到 StockDetail）
- frontend/App.tsx（⏳ 待注册 /followed 路由）

**下一步**：
1. 集成 FollowButton 到 StockDetail.tsx
2. 注册 /followed 路由
3. 真实环境验证 AC1-AC3

**阻塞**：无

**最后更新**：2026-06-18 15:00

---

### v0.4-notification

**状态**：阶段 1 需求中（01-需求.md 写了一半）

**分支**：`feat/v0.4-notification`

**影响文件**：
- backend/services/notification.py（计划）
- docs/versions/active/v0.4-notification/01-需求.md（50% 完成）

**下一步**：
1. 补完 01-需求.md 用户故事 US3-US5
2. 确认通知渠道（邮件 / 站内 / 推送）
3. 进入阶段 2 设计

**阻塞**：
- ⚠️ 依赖 v0.3 完成（共享 user_stock_interests 表）
- ⚠️ 需要确认产品需求（推送渠道优先级）

**最后更新**：2026-06-17 10:30

---

## 📋 TODO（待开始，按优先级排）

### v0.5-payment

**优先级**：P1

**预计开始**：v0.4 完成后

**预估工作量**：3-4 天

**前置依赖**：
- v0.4-notification 完成（支付成功后要通知）
- 申请支付宝 / 微信支付商户号

**备注**：大功能，考虑拆子任务（v0.5-alipay / v0.5-wechat）

---

### v0.6-data-export

**优先级**：P2

**预计开始**：Q3

**备注**：低优先级，等核心功能稳定后再做

---

## ✅ DONE（最近完成，最多保留 5 个）

### v0.2-user-profile

**完成时间**：2026-06-15

**分支**：已 merge 到 main

**产物**：docs/versions/active/v0.2-user-profile/

---

### v0.1-skeleton

**完成时间**：2026-06-10

**分支**：已 merge 到 main

---

## 使用说明

### AI 行为约定

1. **切换任务时**：先 read tasks.md，找到目标任务的"下一步"，快速恢复上下文
2. **任务状态变化时**：更新对应任务的"状态" / "下一步" / "最后更新"
3. **发现阻塞时**：在"阻塞"段标 ⚠️，并在 TODO 段相应调整优先级
4. **任务完成时**：从 DOING 移到 DONE，更新"完成时间"

### 你的使用习惯

**每天开始前**：
```bash
cat .claude/tasks.md
# 看 DOING 段，决定今天先做哪个
```

**任务切换时**：
```bash
claude
> 我现在切到 v0.4-notification，继续写 01-需求.md

# AI 会自动 read tasks.md，看到：
#   v0.4 状态：01-需求.md 写了一半（50%）
#   下一步：补完 US3-US5
# 然后继续写
```

**发现阻塞时**：
```bash
# 手动或让 AI 更新 tasks.md
# 在 v0.4 阻塞段加：
#   ⚠️ 需要确认产品需求（推送渠道优先级）
```

### DOING 段数量建议

- **≤ 2 个**：最佳（专注）
- **3 个**：可接受（适度并行）
- **≥ 4 个**：⚠️ 上下文切换成本过高，建议移一些到 TODO

---

## 与 Standard 的区别

| 维度 | Solo-Multi（本方案）| Standard |
|-----|------------------|----------|
| 文件数 | 1（tasks.md）| 2+（branch-strategy + assignments/<人>）|
| 检查什么 | 自己的任务状态 / 依赖 | 多人冲突 |
| AI 触发时机 | 切换任务时 read | commit / 创建目录 / 改文件时 read |
| 阻塞？ | 不阻塞（信息性）| 半阻塞（A2 二次确认）|

**核心差异**：Solo-Multi 是"帮你记忆"，Standard 是"防多人撞车"。

---

*Harness-Lite v1.0.29-solo-multi · 单人多任务并行追踪板*
