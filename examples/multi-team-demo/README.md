# multi-team-demo · Standard 多人协同示例

> Harness-Lite v1.0.23+ 多人协同机制的真实示例。
> 本示例**专门展示** A1 / A2 / A3 / B1 四个能力的真实工作场景。

---

## 项目设定

3 人虚拟团队，并行开发"用户系统"：

| 成员 | 当前任务 | 影响文件 |
|-----|---------|---------|
| **alice** | v0.1-search-basic（基础搜索） | search.py / search_api.py / test_search.py |
| **bob** | v0.3-user-profile（用户档案） | user.py / profile.py |
| **zoe** | v0.4-user-search（用户搜索） | search.py（与 alice 共享）/ user_api.py |

**关键场景**：zoe 的 v0.4 与 alice 的 v0.1 在 search.py 上有冲突——展示 A3 文件冲突预警如何工作。

---

## 4 能力真实演示

### A1 · 分支命名检查

```bash
# 故意切到违规分支
git checkout -b zoe-experimental

# 准备 commit 时 AI 触发协议
> AI 自检：principles §14.4 commit 前检查
> Read .claude/branch-strategy.md
> 当前分支 'zoe-experimental' 不符 'feat/<short>' 规范
>
> ⚠️ 软提醒不阻塞：
>    继续 commit？(yes/rename)
```

**期望**：用户选 rename → 改 `feat/zoe-user-search` → 静默通过。

---

### A2 · 任务认领冲突预警

```bash
> /harness-req 加用户搜索功能

# AI 在创建版本目录前 read assignments
> 检测到 v0.1-search-basic 已被 alice claim
> 二次确认：
>   [1] 加入协作（多 owner）
>   [2] 改为新版本号
>   [3] 取消
```

**期望**：用户选 [2] → 改 v0.4-user-search → 创建目录 → 追加 zoe.md "进行中" 段。

---

### A3 · 文件冲突预警

```bash
# zoe 改了 src/services/search.py
> /harness-impact

# AI 协议自检
> overlap = 改动文件 ∩ (所有人 claim - 当前用户 claim)
> 
> 报告：
> ⚠️ src/services/search.py
>    被 alice 在 v0.1-search-basic 中 claim（阶段 3 编码中）
>    建议：[1]协作 [2]顺序化 [3]并入多 owner
```

**v1.0.25-final 修后**：自己 claim 的文件不算冲突。

---

### B1 · 协同视角段（自然触发）

查看 `docs/versions/active/v0.4-user-search/` 下任意产物末尾，会自动看到：

```markdown
## 🔍 协同视角

### 📝 PM 视角（用户价值 / 需求回应）
- ...具体可执行的提醒...

### 🧪 QA 视角（边界 / 测试矩阵）
- ...具体可执行的提醒...
```

4 个 skill 都自然触发：
- harness-req → RD + QA 视角
- harness-design → PM + QA 视角
- harness-impact → PM + QA 视角
- harness-test-ci → PM + RD 视角

---

## 文件结构

```
multi-team-demo/
├── .claude/
│   ├── branch-strategy.md        # A1 团队约定
│   ├── assignments/              # A2 任务认领板
│   │   ├── alice.md
│   │   ├── bob.md
│   │   ├── zoe.md
│   │   └── README.md
│   ├── rules/                   # principles §14（多人协同协议）
│   ├── skills/                  # 5 个 skill（含 v1.0.25-final 修复）
│   └── ...
├── src/
│   ├── services/search.py       # 多人共享文件（演示 A3）
│   ├── api/...
│   └── models/...
├── docs/versions/active/v0.4-user-search/
│   ├── 01-需求.md                # 含 B1 协同视角段
│   ├── 02-设计.md                # 含 B1 协同视角段
│   ├── impact-report.md         # 含 B1 + A3 联动
│   └── test-ci-report.md        # 含 B1 协同视角段
└── README.md                    # 本文件
```

---

## 怎么用这个示例

### 1. 看现成产物

直接读 `docs/versions/active/v0.4-user-search/` 下的 4 份产物，看 B1 协同视角段长什么样。

### 2. 复现 A1 / A2 / A3

```bash
cd multi-team-demo
git checkout -b RANDOM-NAME       # 触发 A1
# AI 应在 commit 前 read branch-strategy.md 软提醒

mkdir docs/versions/active/v0.5-test  # 触发 A2 (无冲突)
# AI 应 read assignments 静默执行

echo "// modify" >> src/services/search.py  # 触发 A3
# /harness-impact 应标 ⚠️ 与 alice 的冲突
```

### 3. 修改 assignments 模拟自己

把 `.claude/assignments/zoe.md` 改成自己的姓名，体验 claim 流程。

---

## 与 md-counter 示例的差异

| 维度 | md-counter | multi-team-demo |
|-----|-----------|-----------------|
| 主题 | path-a 5 阶段流程 | v1.0.23+ 多人协同 |
| 团队规模 | 单人 | 3 人虚拟团队 |
| 重点能力 | path-a 模板 | A1 / A2 / A3 / B1 |
| 适合学 | path-a 怎么走 | Standard 怎么用 |

两个示例**互补**，建议先 md-counter（理解流程），再 multi-team-demo（理解协同）。

---

## 已知 dogfooding 发现

本示例**真闭环测试**（v1.0.25-final）暴露过 2 个真 bug，已修：

1. **assignments schema 不感知**（cat >> 错入 done 段）→ assignments/README.md 已加必读警告
2. **A3 自我冲突误判**（把自己 claim 算冲突）→ harness-impact 已加 `(所有人 claim - 当前用户 claim)` 判定

---

## 相关文档

- 决策学习协议指南：[`docs/02-skill-reference/00-decision-learning-guide.md`](../../docs/02-skill-reference/00-decision-learning-guide.md)
- 5 个 skill 用户手册：[`docs/02-skill-reference/`](../../docs/02-skill-reference/)
- principles §13 / §14 协议：[`templates/.claude/rules/principles.md`](../../templates/.claude/rules/principles.md)

---

*Harness-Lite v1.0.25-final · multi-team-demo Standard 协同示例*
