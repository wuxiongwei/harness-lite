# 快速上手 · 5 分钟从零到第一次

> 装好 Harness-Lite，到第一次用上 skill 完成一个真实任务，5 分钟。
>
> 适用：第一次接触 Harness-Lite 的开发者。

---

## 你需要准备

- ✅ macOS / Linux（Windows 需 WSL）
- ✅ [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 已装
- ✅ 一个 git 项目（有 `.git/` 即可，新老项目都行）
- ✅ Harness-Lite 仓库已 clone 到本机（假设在 `~/code/harness-lite/`）

---

## Step 1 · 安装（30 秒）

```bash
cd /path/to/your-project
~/code/harness-lite/scripts/init.sh
```

向导会问 6 件事，**全部回车采用默认值即可**：

```
1. 档位 → 默认 Standard（4-10 人）。单人 / 小团队选 1 (Lite)
2. 项目名 → 自动取目录名
3. 一句话定位 → 自动从 README.md 抽取
4. 业务描述 → 自动从 README.md 抽取
5. 团队规模 → 默认 1-3 人 / 4-10 人（按档位）
6. 项目阶段 → 默认 maintaining
```

> 👀 如果项目有 `pyproject.toml` / `package.json` / `README.md`，向导会自动抽取项目信息预填默认值——你只需空回车。

---

## Step 2 · 启动 claude 自检（10 秒 · 关键步骤）

```bash
claude
```

**预期看到**：直接进入 Claude Code REPL，无任何报错。

**如果看到红色 Settings Error 框**：
- 截图给项目维护者
- 选 "3. Continue without these settings" 暂时绕过（但 hook 不生效）

> 这一步是**最容易跳过、最该做**的：v1.0.5 之前的版本曾因 schema 漂移让 settings.json 加载失败，机制全失效。现在跑一次确认没问题。

---

## Step 3 · 介绍你的项目（30 秒）

进 claude REPL 后：

```
> /clear
> 介绍一下我们项目
```

**预期 AI 回答**：
- 说出你的项目名和业务定位
- 说出技术栈（Python / Java / Node.js 等）
- 说出当前装的 Harness-Lite 版本
- 说出三条路径（A 完整需求 / B 小需求 / C Bug 修复）

如果 AI 答非所问，说明 CLAUDE.md 没被加载——检查 `cat CLAUDE.md` 文件是否在项目根目录。

---

## Step 4 · 第一次用 skill（2 分钟）

随便挑一件你最近想做的小事，比如：

```
> /harness-req 把超时时间从 30 秒改成 60 秒
```

**AI 会做 4 件事**：

1. **自动判定路径**——这件事是"改配置"，归类到**路径 B（小需求）**
2. **创建版本目录**——`docs/versions/active/v0.x-超时时间/`
3. **生成 01-小需求.md**——结构化记录"做什么 / 为什么 / 改哪些文件 / 反向校验"
4. **门控等你确认**——AI 不会私自动手改代码

---

## Step 5 · 看到产物（30 秒）

```bash
cat docs/versions/active/v0.x-超时时间/01-小需求.md
```

你会看到 AI 写好的 6 段：
- 业务诉求（用户原话）
- 改动方案（一段话）
- 改动清单（≤3 文件）
- 影响面快速评估
- 反向校验（4 项 checklist）
- 门控信号（PASS / REVISION / 升级路径 A）

**这就是 Harness-Lite 的核心价值**——
任何代码改动之前，先有结构化记录、影响面、自检。

---

## Step 6 · 实施 + commit（1 分钟）

让 AI 继续：

```
> 按 01-小需求.md 的方案实施
```

AI 会：
1. 改代码
2. 跑全量测试（pre-commit-test.sh hook 会拦截没过的 commit）
3. 等你说"commit"才提交

```
> 跑一下全量测试
> commit
```

> ⚠️ commit 时 `pre-commit-test.sh` 会**自动跑全量测试**。失败会被阻塞，紧急情况可 `HARNESS_SKIP_TEST=1 git commit`。

---

## ✅ 你已经走通了第一个完整流程

```
需求 → 自动路径 → 结构化产物 → 实施 → 全量测试门禁 → commit
```

每一步都有：
- 📄 **产物**（在 `docs/versions/active/`）
- 🛡️ **门禁**（pre-commit-test.sh 拦不安全的 commit）
- 🧠 **AI 上下文隔离**（4 个 subagent 各管一段，不会自写自批）

---

## 接下来

| 想做什么 | 怎么做 |
|---------|-------|
| 完整需求（新功能、>2 天） | `/harness-req <需求>` → AI 自动判定走路径 A |
| 修 bug | `/harness-req <bug 现象>` → AI 自动判定走路径 C |
| 影响面分析 | `/harness-impact`（git diff 后想知道改动影响哪些文件） |
| 全量测试 | `/harness-test-ci`（一次性跑所有测试 + 出门控信号） |
| 一致性审计 | `/harness-review`（在 commit 前审需求/设计/代码/测试是否一致） |

---

## 排错手册

### Q1: `claude` 启动报 Settings Error 怎么办？

→ 选 "2. Exit and fix manually"，跑一遍：
```bash
~/code/harness-lite/scripts/validate.sh
```
看哪条不变式不通过。**通常是 schema 不兼容**——可能你装的是老版本，跑：
```bash
~/code/harness-lite/scripts/upgrade.sh
```

### Q2: skill `/harness-req` 找不到？

→ 检查目录：`ls .claude/skills/`。应该有 5 个 `harness-*/`。如果空 → 没装好，重跑 `init.sh`。

### Q3: `pre-commit-test.sh` 一直拦着 commit？

→ **这是设计**。看输出的失败用例，修了再 commit。**紧急情况**才用 `HARNESS_SKIP_TEST=1 git commit`，**不要默认跳过**。

### Q4: 想撤掉 Harness-Lite

```bash
~/code/harness-lite/scripts/uninstall.sh
```

会清掉 H-L 文件，**保留**你的：
- `team-knowledge/`（团队知识库）
- `docs/versions/active/`（你的需求版本）
- `CLAUDE.md`（备份再卸）

### Q5: 升级到新版本

```bash
~/code/harness-lite/scripts/upgrade.sh
```

会自动备份旧版到 `.harness-lite-upgrade-backup/{时间戳}/`，再覆盖 H-L 文件。
**用户数据完全不动**。

---

## 进阶阅读

- [产品愿景](../00-product-spec/01-vision.md) — 这个产品想解决什么
- [价值主张](../00-product-spec/02-value-proposition.md) — 用了能得到什么
- [产品边界](../00-product-spec/04-scope-boundary.md) — 不解决什么

📝 待补（v1.1+ 写）：
- 三条路径（A/B/C）的选择手册
- 5 个 skill 的详细参考
- 4 个 subagent 的协作机制
- 工作流总览
- 速查表

---

*Harness-Lite v1.0.10 · 快速上手 · 5 分钟版*
