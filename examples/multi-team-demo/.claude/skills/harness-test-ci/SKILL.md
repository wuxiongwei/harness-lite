---
name: harness-test-ci
description: |
  全量回归 + CI 质量门禁。每次 AI 改完代码后调用，自动检测测试框架（Python/Java/Node.js/Go），
  全量运行测试，输出分层测试报告，给出 PASS / BLOCKED 门控信号。
  典型触发：用户说"全量测试"、"跑测试"、"回归测试"、"测试通过了吗"，或编码完成进入验收前。
---

# /harness-test-ci · 全量回归 CI skill

> **每次 AI 改完代码后必须调用** · 保证整个项目没有被破坏

---

## 核心价值

AI 只知道它改了什么，不知道它影响了什么。

```
AI 改了 UserService
    ↓
UserService 被 OrderService / PayService / EmailService 调用
    ↓
但 AI 不知道这些调用关系
    ↓
全量测试跑一遍 → 立刻暴露所有被影响的地方
```

**全量测试是最快的影响面发现机制**，比任何静态分析都可靠。

---

## 触发时机

```
编码（implementer subagent）完成
    ↓
/harness-test-ci    ← 此时调用
    ↓
全量通过 → /harness-review（一致性审计）
    ↓
全量失败 → 🔴 BLOCKED，返回 implementer 修复
```

---

## Phase 1：环境检测

```bash
# 检测技术栈
if [ -f "pom.xml" ]         → Java Maven
if [ -f "build.gradle" ]    → Java Gradle
if [ -f "pyproject.toml" ]  → Python
if [ -f "package.json" ]    → Node.js
if [ -f "go.mod" ]          → Go

# 检测测试框架
pytest / junit / jest / gotest / ...
```

---

## Phase 2：Lint 快速检查（非阻塞，先报告）

目的：让开发者在等待测试的同时先看到 lint 问题。

```bash
# Python
ruff check . --select=E,W,F --ignore=E501

# Java（Checkstyle 通常在 Maven test 中包含）
mvn checkstyle:check -q

# Node.js
npm run lint --if-present
```

lint 问题只警告，**不阻塞**测试流程。

---

## Phase 3：全量测试执行

### 强制约束（铁律）

```
❌ 禁止：
  - 只跑改动文件相关的测试
  - 只跑某个测试目录
  - 跳过任何已有的测试

✅ 必须：
  - 全量跑（所有测试文件）
  - -x 快速失败（遇到第一个失败立即停止）
  - 真实环境（不 mock 数据库 / 外部服务）
```

### 按技术栈执行

```bash
# Python
pytest tests/ -x -q --tb=short [--cov=. --cov-report=term-missing]

# Java Maven
mvn test

# Java Gradle
./gradlew test

# Node.js
npm test

# Go
go test ./... -count=1 -timeout=120s
```

---

## Phase 4：影响面快速分析

在测试运行期间（或测试通过后），分析本次改动的影响面：

```bash
# 找出本次改动文件
git diff --name-only HEAD

# 分析调用关系（找谁调用了改动文件中的函数/类）
grep -rn "import.*UserService\|from.*UserService" --include="*.py" src/
```

输出：
```
本次改动文件：
  - src/services/user_service.py

被影响的模块（依赖分析）：
  - src/api/user_api.py（直接调用）
  - src/workflows/onboarding.py（间接依赖）
  - tests/test_user_api.py（测试覆盖）

覆盖情况：
  ✅ user_service.py → 有对应测试（test_user_service.py）
  ✅ user_api.py → 有对应测试（test_user_api.py）
  ⚠️ onboarding.py → 无直接测试（通过集成测试覆盖）
```

---

## Phase 4.5：决策点处理（v1.0.21+ · principles §13）

遇到决策点（≥ 2 个合理选项）时，按 principles §13 流程：查 auto-decide → 命中自决+标注 / 未命中询问+记 log。

**典型决策点（harness-test-ci）**：
- 全量 vs 增量（全量回归 / 仅本次相关）
- 失败时策略（fast-fail / 继续跑完）
- 测试报告粒度（简要 / 详细 / 附日志）

---

## Phase 4.7：协同视角段（v1.0.23+ · principles §14）

测试报告末尾追加：

```markdown
---

## 🔍 协同视角（v1.0.23+）

### 📝 PM 视角（用户场景覆盖）
- 失败用例是否对应 01-需求.md 的某个 AC？
- 测试覆盖率是否对应需求"不做的范围"之外的所有用户故事？

### 🛠️ RD 视角（实现假设）
- 失败用例是否暴露设计阶段的实现假设错误？
- 是否需要回到 02-设计.md 修订？
```

**质量约束**：每视角 ≥ 2 条、具体可执行、无空话。

---

## Phase 5：测试报告生成

输出位置：`docs/versions/active/v{X.Y}-{slug}/test-ci-report.md`

```markdown
# CI 测试报告 · v{VERSION}-{SLUG}

## 执行信息
- 执行时间：{TIMESTAMP}
- 技术栈：{STACK}
- 测试框架：{FRAMEWORK}

## Lint 结果
| 检查项 | 状态 | 问题数 |
|-------|------|-------|
| ruff | ✅/⚠️ | N |

## 分层测试结果

### Layer 1 · 单元测试
- 总数：N
- 通过：N
- 失败：0
- 跳过：0
- 覆盖率：X%（阈值：Y%）

### Layer 2 · 集成测试
- 总数：N
- 通过：N
- 失败：0

### Layer 3 · E2E 测试（如有）
- 总数：N
- 通过：N

## 影响面分析
- 改动文件：N 个
- 直接依赖：N 个模块
- 测试覆盖率：N / N 改动文件有对应测试

## 失败详情（如有）
（失败测试列表 + 错误信息）

## 门控信号
状态：🟢 PASS / 🔴 BLOCKED
原因：（如 BLOCKED，说明哪个测试失败）
```

---

## Phase 6：门控决策

### 🟢 PASS 条件
- 所有测试通过
- 覆盖率 ≥ 配置阈值（默认不要求）
- 本次改动文件都有对应测试（渐进策略下可选）

### 🔴 BLOCKED 条件（任一满足）
- **有测试失败**（无论是不是本次改动引起的）
- **Layer 3 E2E 失败**
- **本次改动文件无任何测试覆盖**（渐进策略强制时）

```
BLOCKED 时：
  1. 输出失败原因（哪个测试、哪一行）
  2. 判断根因：本次改动引起 vs 历史已有失败
  3. 本次引起 → 返回 implementer 修复
  4. 历史已有 → 报告给用户，明确不是本次引入
  5. 无论如何，都不允许"带着失败 commit"
```

---

## 渐进策略支持（对老项目）

老项目很多文件没有测试。`/harness-test-ci` 支持两种模式：

### 模式1：全量模式（默认）
- 跑所有已有测试
- 不强制"新改文件有对应测试"
- 适合：测试体系已相对完善的项目

### 模式2：渐进模式（`--progressive`）
- 跑所有已有测试
- **额外检查**：本次改动文件是否有对应测试
- 没有 → 强制先补测试（RED），再修代码（GREEN）
- 适合：老项目正在逐步建立测试体系

```
/harness-test-ci --progressive
```

---

## 使用示例

### 正常 CI 调用

```
用户：/harness-test-ci

skill 行动：
  Phase 1：检测到 Python + pytest
  Phase 2：ruff lint → 2 个 warning（非阻塞）
  Phase 3：pytest tests/ -x -q → 47 通过 / 0 失败
  Phase 4：分析影响面 → 3 个文件受影响，全部有测试
  Phase 5：生成 test-ci-report.md

输出：
  ✅ Lint：2 个 warning（已记录）
  ✅ 单元测试：47/47 通过
  ✅ 影响面：3 个文件，100% 有测试
  
  🟢 PASS · 可进入 /harness-review
```

### 测试失败场景

```
Phase 3：pytest tests/ -x -q → 第 12 个测试失败

输出：
  ❌ 失败：tests/test_order.py::test_cancel_order
  错误：AssertionError: expected 'CANCELLED' got 'PENDING'
  
  根因分析：
    本次改动了 order_service.py 的 cancel_order 方法
    该方法的状态转换逻辑与测试预期不符
  
  🔴 BLOCKED
  → 返回修复 order_service.py 的 cancel_order 状态转换
  → 修复后重新运行 /harness-test-ci
```

---

## 与工作流的集成

在 `docs/versions/active/{slug}/` 的完整路径A工作流中：

```
01-需求 → 02-设计 → [implementer 编码] → /harness-test-ci → /harness-review → 04-测试
                                              ↑
                                         此处调用
```

`/harness-test-ci` 的报告会被写入 `test-ci-report.md`，`04-测试.md` 直接引用。

---

*Harness-Lite v1.0.0 · /harness-test-ci · 全量回归CI*
