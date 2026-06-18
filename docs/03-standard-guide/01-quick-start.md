# Standard 快速开始指南

> 5 分钟启用 Harness-Lite Standard 多人协同能力

---

## 什么是 Standard

Standard 是 Harness-Lite v1.0.23+ 的**多人协同模式**，提供：

| 能力 | 作用 | 自动触发时机 |
|-----|------|------------|
| **A1 分支命名检查** | 防止违规分支名 | git commit / push 前 |
| **A2 任务认领冲突预警** | 防止多人重复开发 | 创建新版本目录前 |
| **A3 文件冲突预警** | 防止多人同时改同一文件 | /harness-impact 分析时 |
| **B1 协同视角段** | 自动补充 RD/PM/QA 视角 | 4 skill 主产物末尾 |

**与 Lite 的区别**：
- Lite（默认）：单人或小团队（2 人以内），无协同机制
- **Standard**：2+ 人团队，有协同基础设施

---

## 前置条件

- ✅ 已安装 Harness-Lite v1.0.23+
- ✅ 项目已初始化（跑过 `scripts/init.sh`）
- ✅ 团队 ≥ 2 人

---

## 5 分钟启用 Standard

### Step 1：创建分支策略文件（1 分钟）

```bash
# 已有模板，直接复制
cp .claude/templates/.claude/branch-strategy.md .claude/branch-strategy.md

# 或手动创建
cat > .claude/branch-strategy.md << 'EOF'
# 分支策略（团队约定）

## 命名规范

```
feat/<short-name>          # 新功能
fix/<short-name>           # bug 修复
refactor/<short-name>      # 重构
docs/<short-name>          # 文档
chore/<short-name>         # 杂项
hotfix/<short-name>        # 紧急修复
```

## 主分支保护

- `main`：禁止直接 push，必须 PR
- 合并要求：review + CI 通过

## 合并规则

- 小功能：squash merge
- 大重构：merge commit（保留历史）
EOF

# 入仓库（Standard 文件必须团队共享）
git add .claude/branch-strategy.md
git commit -m "feat: 启用 Standard 分支策略"
```

**验证**：下次 commit 时，AI 会自动检查分支名。

---

### Step 2：创建任务认领板（2 分钟）

```bash
# 为每个团队成员创建 assignments 文件
mkdir -p .claude/assignments

# 成员 1（alice）
cat > .claude/assignments/alice.md << 'EOF'
# 任务认领（alice）

## 进行中（claimed）

—

## 待办（pending）

—

## 已完成（done）

—
EOF

# 成员 2（bob）
cat > .claude/assignments/bob.md << 'EOF'
# 任务认领（bob）

## 进行中（claimed）

—

## 待办（pending）

—

## 已完成（done）

—
EOF

# 复制 README（AI 行为约定）
cp .claude/templates/.claude/assignments/README.md .claude/assignments/

# 入仓库
git add .claude/assignments/
git commit -m "feat: 启用 Standard 任务认领板"
```

**验证**：下次创建新版本时，AI 会检查 claim 冲突。

---

### Step 3：第一次真实触发（2 分钟）

**场景 1 · 触发 A1（分支命名检查）**：

```bash
# 故意切到违规分支
git checkout -b my-feature

# 让 AI 做任意改动 + commit
claude
> 帮我在 README 加一行 "test"

# AI 准备 commit 时会触发 A1：
#   ⚠️ 当前分支 my-feature 不符规范
#   建议：feat/my-feature
#   继续 commit？(yes/rename)

# 你回答 "rename"，AI 会自动 git branch -m feat/my-feature
```

**场景 2 · 触发 A2（任务认领冲突）**：

```bash
# alice 先 claim 一个任务
# 在 .claude/assignments/alice.md "进行中"段加：
### v0.1-user-login
- claim 时间：2026-06-18
- 状态：阶段 2 设计中
- 影响文件：
  - src/auth/login.py

# 你（bob）尝试做类似任务
claude
> /harness-req 加用户登录功能

# AI 创建版本目录前会触发 A2：
#   ⚠️ v0.1-user-login 已被 alice claim
#   [1] 加入协作（多 owner）
#   [2] 改为新版本号
#   [3] 取消
```

---

## 验证 Standard 是否启用

```bash
# 检查文件存在
ls .claude/branch-strategy.md
ls .claude/assignments/*.md

# 跑 validate（v1.0.26+ 含 §14 检查）
bash scripts/validate.sh

# 应看到：
# ✓ §14 协同 schema 通过
```

---

## 下一步

- 📖 阅读 [4 能力用户手册](02-standard-capabilities.md)（深入了解 A1/A2/A3/B1）
- 📖 阅读 [多人协同最佳实践](03-standard-best-practices.md)（2-3 人 vs 5+ 人团队）
- 🎯 参考 [examples/multi-team-demo](../../../examples/multi-team-demo)（真实 3 人团队示例）

---

## 常见问题

### Q1：Lite 升级到 Standard 需要改代码吗？

**不需要**。Standard 是纯协议层 + 共享文件，代码无需改。

### Q2：可以部分启用 Standard 吗（比如只要 A1 不要 A2）？

可以：
- 只创建 branch-strategy.md → 只启用 A1
- 只创建 assignments/ → 只启用 A2/A3
- B1 协同视角段默认开启（无依赖文件）

### Q3：单人项目能用 Standard 吗？

可以但**不推荐**——Standard 的协同检查对单人是冗余。单人项目用 Lite 即可。

### Q4：现有项目中途启用 Standard 有风险吗？

无风险：
- .claude/branch-strategy.md 不存在 → 跳过 A1
- .claude/assignments/ 不存在 → 跳过 A2/A3
- 向下兼容 v1.0.22 行为

---

*Harness-Lite v1.0.28-standard-production · 快速开始指南*
