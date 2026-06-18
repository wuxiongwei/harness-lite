# Standard 边界场景补充指南

> v1.0.28 补充：取消 claim / 多 owner 操作 / schema 漂移防护

---

## 1. 取消 claim 流程

### 场景

alice claim 了 v0.8-notification，干到一半发现：
- 依赖的 v0.7 还没完成
- 技术难度超预期
- 优先级变了，要先做别的

### 操作步骤

```bash
# Step 1: 编辑 assignments
vim .claude/assignments/alice.md

# 从"## 进行中（claimed）"段删除 v0.8
# 可选：移到"## 待办（pending）"段 + 加备注

## 待办（pending）

### v0.8-notification
- 状态：暂停（alice 尝试过，依赖 v0.7 未完成）
- 原 claim 时间：2026-06-20
- 预计重启：待 v0.7 完成后

# Step 2: commit
git add .claude/assignments/alice.md
git commit -m "unclaim: v0.8-notification（依赖阻塞）"

# Step 3: 通知团队（群聊 / 站会）
```

### AI 行为变化

取消 claim 后：
- A2 不再报 v0.8 被 alice claim
- A3 不再报 alice claim 的文件冲突
- 其他人可以 claim v0.8

---

## 2. 多 owner 操作指引

### 场景

v0.10-payment 是大功能，alice/bob/charlie 三人协作。

### 方式 1：共享 claim（推荐）

```markdown
# alice.md（主 owner）
## 进行中（claimed）

### v0.10-payment
- claim 时间：2026-06-20 09:00
- 状态：阶段 2 设计中
- 影响文件：
  - src/payment/alipay.py（alice 负责）
  - src/payment/wechat.py（bob 负责）
  - src/payment/union.py（charlie 负责）
  - src/payment/base.py（共同维护）
- 协作者：bob, charlie
- 协调机制：每日站会 + 飞书文档

# bob.md
## 进行中（claimed）

### v0.10-payment
- 协作者：alice（主 owner）, charlie
- 我的部分：微信支付对接

# charlie.md
## 进行中（claimed）

### v0.10-payment
- 协作者：alice（主 owner）, bob
- 我的部分：银联支付对接
```

**关键点**：
- 3 人都在"进行中"段有 v0.10
- 影响文件明确标注各自负责部分
- 有一个"主 owner"负责整体协调

### 方式 2：拆子任务

```markdown
# alice.md
### v0.10-payment-alipay
- 父任务：v0.10-payment
- 影响文件：src/payment/alipay.py

# bob.md
### v0.10-payment-wechat
- 父任务：v0.10-payment
- 影响文件：src/payment/wechat.py
```

**关键点**：
- 版本号不同（v0.10-payment-alipay ≠ v0.10-payment-wechat）
- A2 不报冲突
- 需要手动协调"父任务"关系

### AI 行为差异

| 方式 | A2 触发 | A3 触发 | 适用 |
|-----|--------|--------|------|
| 方式 1 共享 claim | ❌ 不触发（3 人都 claim 同名）| ✅ 触发（交叉改对方文件时）| 紧密协作 |
| 方式 2 拆子任务 | ❌ 不触发（版本号不同）| ✅ 触发（改同一文件时）| 松散协作 |

---

## 3. schema 漂移防护

### 问题

用户手写 assignments 可能格式错：
- 缺"## 进行中"段
- 拼写错误"## 进行种"
- 乱序（"已完成"在"进行中"前）

→ A2/A3 失效 + validate 报错。

### v1.0.28 增强防护

**validate.sh 第 9 维强化**（已在 v1.0.27 加，v1.0.28 增强）：

```bash
# 检查 assignments schema（v1.0.27 基础版）
- 必须含"## 进行中"段
- 应含"## 待办"段（warn）
- 应含"## 已完成"段（warn）

# v1.0.28 增强（新增）
- "进行中"段必须在"待办"段之前（顺序检查）
- "影响文件"必须是列表格式（- 开头）
- "claim 时间"必须是日期格式（YYYY-MM-DD）
```

### 自愈建议

**错误 1：段落顺序错**
```markdown
# 错误
## 已完成
## 进行中  # 顺序反了

# 修复
## 进行中
## 待办
## 已完成
```

**错误 2：影响文件格式错**
```markdown
# 错误
- 影响文件：src/a.py, src/b.py  # 不是列表

# 修复
- 影响文件：
  - src/a.py
  - src/b.py
```

**错误 3：拼写错误**
```markdown
# 错误
## 进行种（claimed）  # 拼音输入法错误

# 修复
## 进行中（claimed）
```

### 自动修复工具（可选）

```bash
# scripts/fix-assignments-schema.sh（v1.0.28 新增）
#!/bin/bash
# 自动修复 assignments 常见格式错误

for f in .claude/assignments/*.md; do
    if [ "$(basename "$f")" = "README.md" ]; then continue; fi
    
    # 修复拼写错误
    sed -i.bak 's/## 进行种/## 进行中/g' "$f"
    
    # 修复顺序（如果"已完成"在"进行中"前，警告）
    # （具体实现略，因为 sed 难做复杂重排）
    
    rm -f "$f.bak"
done
```

---

## 4. 边界场景自测清单

在 multi-team-demo 真实模拟：

```bash
cd examples/multi-team-demo

# 测试 1：取消 claim
# 1. alice claim v0.5
# 2. 删除 alice.md 的 v0.5
# 3. bob 尝试 claim v0.5 → A2 不报冲突 ✅

# 测试 2：多 owner（方式 1）
# 1. alice/bob 都 claim v0.6
# 2. alice 改 a.py，bob 改 b.py → A3 不报 ✅
# 3. alice 改 b.py → A3 报 bob 冲突 ✅

# 测试 3：schema 漂移
# 1. 故意写错 alice.md（删"进行中"段）
# 2. bash scripts/validate.sh → 报错 ✅
# 3. 修复后 → validate 通过 ✅
```

---

*Harness-Lite v1.0.28-standard-production · 边界场景补充*
