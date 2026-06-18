# 任务认领板（团队共享）

> 本目录**入仓库**，团队共享。
> 每人创建 `.claude/assignments/<姓名>.md` 记录自己的任务认领。
> AI 在 `/harness-req` 创建版本目录前会查所有人的 assignments 文件，提醒任务冲突。

---

## 文件命名规范

每人一个文件：`.claude/assignments/<姓名>.md`

例：
- `.claude/assignments/alice.md`
- `.claude/assignments/bob.md`
- `.claude/assignments/zoe.md`

姓名建议用 git config user.name 或团队约定。

---

## 文件结构（统一模板）

```markdown
# 任务认领（<姓名>）

## 进行中（claimed）

### v0.X-<slug>
- claim 时间：YYYY-MM-DD HH:MM
- 状态：阶段 X 中
- 影响文件：（可选，给冲突预警提供精确锚点）
  - src/services/xxx.py
  - src/api/yyy.py
- 协作者：（如有多 owner）

## 待办（pending）

- v0.Y-<slug> · 待 v0.X 完成

## 已完成（done）

### v0.Z-<slug>
- 完成时间：YYYY-MM-DD
- 协作者：（如有）
```

---

## 字段语义

| 段 | 用途 | AI 行为 |
|---|------|--------|
| 进行中（claimed） | 当前 claim 的任务 | 检测冲突主要查这段 |
| 待办（pending） | 未来计划 | 不主动检查（仅记录） |
| 已完成（done） | 历史归档 | 不影响冲突检测 |
| 影响文件 | 精确锚点 | `/harness-impact` 用此交叉判断冲突 |

---

## AI 行为约定

### 1. claim 新任务时（/harness-req 创建版本目录前）

```
Read .claude/assignments/*.md（所有人）
   ↓
检查目标 v0.X-slug 是否被 claim？
├─ 是 → 提醒：
│       "⚠️ alice 已 claim v0.X-slug。
│        [1] 加入协作（多 owner）
│        [2] 改为新版本号
│        [3] 取消"
└─ 否 → 静默执行 + 追加到当前用户 assignments 的"进行中（claimed）"段
```

**⚠️ v1.0.25 真闭环测试暴露的 bug · 必读**：

追加新 claim 到 assignments 时，**必须插入"进行中（claimed）"段**，不能 cat >> 简单追加到文件末尾（会错误插入"已完成（done）"段）。

正确做法：
1. Read 当前 assignments 文件全文
2. 找到 `## 进行中（claimed）` 标题
3. 在该段（下一个 `## ` 标题前）插入新 claim
4. Write 全文

错误做法（会触发 bug）：
- ❌ `cat >> file` 无脑追加（错入 done 段）
- ❌ Edit 工具用末尾段落字符串匹配（会搞错段落）

### 2. 影响面分析时（/harness-impact）

```
Read .claude/assignments/*.md "进行中" 段
   ↓
for 任务 in 所有 claim:
    if 改动文件 ∩ 任务影响文件 ≠ ∅:
        报告标 ⚠️：
        "⚠️ 你改的 src/services/user.py
         也被 alice 在 v0.X 中 claim"
```

### 3. 完成任务时

用户手动改 my assignments：
- 把"进行中"段的任务移到"已完成"段
- 加 `完成时间`

AI **不会自动迁移**——避免误改用户认领状态。

---

## 多 owner 协作

允许多人 claim 同一任务：
- 各自的 assignments 文件都有该任务记录
- 标 `协作者：alice, bob`
- AI 后续检测冲突时识别"多 owner"，仅做提示不再二次确认

---

## 与 v1.0.21 决策学习的差异

| 维度 | v1.0.21 决策学习 | v1.0.23 任务认领 |
|-----|-----------------|-----------------|
| 文件位置 | `.claude/decision-log.md` | `.claude/assignments/<人>.md` |
| 入仓库？ | ❌ gitignore | ✅ 入仓库 |
| 适用 | 个人偏好 | 团队协同 |

---

## 向下兼容

`.claude/assignments/` 目录不存在或为空时，AI 跳过冲突预警（行为同 v1.0.22）。

---

*Harness-Lite v1.0.23+ 多人协同协议·任务认领板*
