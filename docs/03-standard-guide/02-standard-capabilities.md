# Standard 4 能力用户手册

> A1 / A2 / A3 / B1 深入解析 + 故障排查

---

## 能力总览

| 能力 | 触发时机 | 用户感知 | 阻塞？ |
|-----|---------|---------|-------|
| **A1 分支命名检查** | git commit / push 前 | AI 软提醒 | ❌ 不阻塞 |
| **A2 任务认领冲突预警** | 创建新版本目录前 | AI 二次确认 | ⚠️ 半阻塞（需用户选择）|
| **A3 文件冲突预警** | /harness-impact 时 | 报告标 ⚠️ | ❌ 不阻塞 |
| **B1 协同视角段** | 4 skill 主产物末尾 | 产物自动追加段落 | ❌ 不阻塞 |

**设计哲学**：软提醒不阻塞——Standard 协同机制是"辅助决策"，不是"强制管控"。

---

## A1 · 分支命名检查

### 触发时机

AI 准备执行 `git commit` 或 `git push` 前。

### 工作流程

```
AI 准备 git commit
    ↓
Read .claude/branch-strategy.md
    ↓
取当前分支名：git rev-parse --abbrev-ref HEAD
    ↓
匹配规范（feat/fix/refactor/docs/chore/hotfix）
    ↓
┌─ 符合 → 静默通过（用户无感知）
└─ 不符合 → 软提醒（不阻塞）：
   "⚠️ 当前分支 my-feature 不符规范
    建议：feat/my-feature
    继续 commit？(yes/rename)"
```

### 用户响应

| 选项 | AI 行为 |
|-----|--------|
| `yes` | 继续 commit（允许违规）|
| `rename` | 执行 `git branch -m feat/my-feature` 后 commit |

### 常见场景

**场景 1 · 个人实验分支**：
```
分支：zoe-experimental
AI 提醒：不符规范，建议 feat/zoe-experimental
你回：yes（个人分支无所谓）
```

**场景 2 · 团队协作分支**：
```
分支：user-login
AI 提醒：不符规范，建议 feat/user-login
你回：rename（团队需要统一）
```

### 故障排查

**现象 1：AI 没触发 A1**
- 检查 `.claude/branch-strategy.md` 是否存在
- 检查文件是否含 6 类前缀关键词（feat/fix/...）
- 跑 `bash scripts/validate.sh`，看 §14 检查是否通过

**现象 2：AI 误报违规**
- 检查 branch-strategy.md 的正则规则是否太严
- 如果规则是自定义的（不是模板），确认格式正确

**现象 3：rename 后仍提示**
- 可能是 git branch -m 失败（分支名冲突）
- 手动 `git branch -m <新名>` 再 commit

---

## A2 · 任务认领冲突预警

### 触发时机

AI 准备创建 `docs/versions/active/vX.Y-slug/` 目录前（通常是 /harness-req 第一步）。

### 工作流程

```
AI 准备创建 docs/versions/active/v0.3-user-login/
    ↓
Read .claude/assignments/*.md（所有人）
    ↓
检查 v0.3-user-login 是否被 claim
    ↓
┌─ 否 → 静默执行 + 追加到当前用户 assignments "进行中"段
└─ 是 → 二次确认（半阻塞）：
   "⚠️ v0.3-user-login 已被 alice claim（阶段 2 设计中）
    [1] 加入协作（多 owner）
    [2] 改为新版本号（如 v0.4-user-login-enhanced）
    [3] 取消"
```

### 用户响应

| 选项 | AI 行为 | 适用场景 |
|-----|--------|---------|
| `[1] 加入协作` | 在 alice 的 assignments 加你为协作者 + 继续创建目录 | alice 同意一起做 |
| `[2] 改名` | AI 建议新版本号，你确认后创建新目录 | 功能有差异，独立做 |
| `[3] 取消` | 不创建目录，退出 /harness-req | 等 alice 做完再说 |

### 常见场景

**场景 1 · 真冲突（重复开发）**：
```
alice claim: v0.3-user-login（登录功能）
你尝试: v0.3-user-login（同名）
→ 选 [2] 改名 v0.4-user-login-sso（你做 SSO 登录）
```

**场景 2 · 协作开发**：
```
alice claim: v0.5-payment（支付模块，大功能）
你协助: v0.5-payment（一起做）
→ 选 [1] 加入协作
```

**场景 3 · 关键词部分重叠但不冲突**：
```
alice claim: v0.1-search-basic（基础搜索）
你尝试: v0.4-user-search（用户搜索）
→ AI 判定：版本号不同 + 语义不同 → 不报冲突（静默通过）
```

### 故障排查

**现象 1：AI 没触发 A2**
- 检查 `.claude/assignments/` 目录是否存在
- 检查至少有一个 `<人>.md` 文件（不只 README.md）
- 跑 `bash scripts/validate.sh`，看 §14 检查

**现象 2：AI 误报冲突**
- A2 是严格版本号匹配（v0.3-user-login ≠ v0.4-user-login）
- 如果 AI 报了不该报的，可能是你用了完全相同的版本号

**现象 3：选 [1] 协作后，alice 的 assignments 没更新**
- 检查 AI 是否真 edit 了 alice.md（看 git diff）
- 手动补：在 alice.md 对应任务加 `- 协作者：你的名字`

**现象 4：追加到 assignments 时写错段落**
- v1.0.25-final 修复的 bug：AI 应插入"进行中"段，不是文件末尾
- 如果仍出现，检查 H-L 版本是否 ≥ v1.0.25-final

---

## A3 · 文件冲突预警

### 触发时机

执行 `/harness-impact` 影响面分析时。

### 工作流程

```
/harness-impact
    ↓
git diff --name-only（取改动文件）
    ↓
Read .claude/assignments/*.md 所有人"进行中"段
    ↓
计算：overlap = 改动文件 ∩ (所有人 claim - 当前用户 claim)
    ↓
┌─ overlap = ∅ → 报告正常（无冲突预警）
└─ overlap ≠ ∅ → 报告标 ⚠️：
   "## 🤝 协作冲突预警
   
   ⚠️ src/services/search.py
      被 alice 在 v0.1-search-basic 中 claim（阶段 3 编码中）
   
   建议：
   - [1] 与 alice 沟通拆分（推荐）
   - [2] 顺序化（等 v0.1 完成）
   - [3] 并入 v0.1（多 owner）"
```

### 用户响应

A3 是**信息性提醒**（不阻塞），你看到后自己决定：
- 去找 alice 沟通拆分
- 或等 alice v0.1 完成
- 或两人合并到一个任务

### 常见场景

**场景 1 · 同一文件不同函数**：
```
alice 改：src/services/search.py（加 basic_search 函数）
你改：src/services/search.py（加 user_search 函数）
→ A3 报 ⚠️ → 你们沟通：一个人先 merge，另一个 rebase
```

**场景 2 · 完全独立的文件**：
```
alice 改：src/auth/login.py
你改：src/payment/alipay.py
→ A3 不报（无 overlap）
```

**场景 3 · 自己 claim 的文件自己改**：
```
你 claim v0.5-payment，影响 payment.py
你改 payment.py
→ A3 不报（v1.0.25-final 修复：排除自己 claim）
```

### 故障排查

**现象 1：AI 没触发 A3**
- A3 是 /harness-impact 的一部分，如果没生成报告就没触发
- 检查 AI 是否真执行了 `git diff` + read assignments

**现象 2：误报自己 claim 的文件**
- 应该在 v1.0.25-final 修复了
- 检查 H-L 版本 ≥ v1.0.25-final
- 检查 templates/.claude/skills/harness-impact/SKILL.md Phase 3.7 是否含"排除当前用户 claim"

**现象 3：真冲突但没报**
- 检查 alice 的 assignments 里"进行中"段是否真有那个文件
- 检查文件路径是否完全匹配（src/search.py ≠ search.py）

---

## B1 · 协同视角段

### 触发时机

4 个 skill 生成主产物末尾时：
- harness-req → 01-需求.md 末尾
- harness-design → 02-设计.md 末尾
- harness-impact → 影响面报告末尾
- harness-test-ci → 测试报告末尾

（harness-review 不接，已是审计性质）

### 工作流程

```
AI 完成主产物写作
    ↓
principles §14.5 触发
    ↓
在产物末尾追加：
---

## 🔍 协同视角（v1.0.23+）

### {辅助视角 1 emoji + 角色}
- {具体提醒 1}
- {具体提醒 2}
- ...

### {辅助视角 2 emoji + 角色}
- ...
```

### 视角组合表

| skill | 主写者 | 辅助视角 1 | 辅助视角 2 |
|------|-------|----------|----------|
| harness-req | PM | 🛠️ RD 视角 | 🧪 QA 视角 |
| harness-design | RD | 📝 PM 视角 | 🧪 QA 视角 |
| harness-impact | RD | 📝 PM 视角 | 🧪 QA 视角 |
| harness-test-ci | QA | 📝 PM 视角 | 🛠️ RD 视角 |

### 质量要求

每视角 ≥ 2 条具体可执行提醒：
- ✅ "estimate：1-2 人天"
- ✅ "边界：空查询、特殊字符、超长输入"
- ❌ "建议关注用户价值"（空话）

### 常见场景

**场景 1 · 01-需求.md 末尾**：
```markdown
## 🔍 协同视角

### 🛠️ RD 视角（实现可行性 / 估时 / 风险）
- 实现路线分叉：用 SQL LIKE 还是单独索引？
- estimate：1-2 人天
- 风险：与 alice v0.1 同时改 search.py → 必须协调

### 🧪 QA 视角（边界 / 测试矩阵 / 性能）
- 边界：空查询、特殊字符、超长输入
- 测试矩阵：3 种搜索 × 4 种边界 = 12 用例
- 性能：500ms 阈值需在 1000 用户数据集验证
```

### 故障排查

**现象 1：产物末尾没有协同视角段**
- 检查 H-L 版本 ≥ v1.0.23
- 检查 skill SKILL.md 是否含 Phase X.7 协同视角段指引
- v1.0.26 A1 测试已验证 4 skill 全部自然触发——如果没触发，是 bug

**现象 2：协同视角段只有空话**
- 检查 principles §14.5："禁止流于形式"
- harness-review 维度5 应该审计质量（但可能漏过）
- 手动补充具体提醒

**现象 3：视角组合错了**
- 检查 skill SKILL.md Phase X.7 指引
- 应该按上表（req→RD+QA，design→PM+QA，...）

---

## 4 能力联动场景

### 场景 1 · A2 + A3 联动

```
alice claim v0.1-search-basic，影响 search.py
你尝试 v0.2-search-advanced
→ A2 不报（版本号不同）
→ 但你改 search.py 时 A3 报 ⚠️（文件冲突）
```

### 场景 2 · A3 + B1 联动

```
/harness-impact 报告：
- A3 标 ⚠️ 与 alice search.py 冲突
- B1 PM 视角：本次改动不影响已有用户
- B1 QA 视角：alice 的测试必须全部通过（回归风险）
```

### 场景 3 · A1 + A2 + A3 全触发

```
1. 违规分支 my-feature → A1 提醒 rename
2. 创建 v0.3-login（与 alice 冲突）→ A2 提醒改名
3. 改 auth.py（alice claim）→ A3 标 ⚠️
```

---

## 下一步

- 📖 阅读 [多人协同最佳实践](03-standard-best-practices.md)
- 🎯 参考 [examples/multi-team-demo](../../../examples/multi-team-demo)

---

*Harness-Lite v1.0.28-standard-production · 4 能力用户手册*
