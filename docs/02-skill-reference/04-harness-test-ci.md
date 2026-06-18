# `/harness-test-ci` 用户手册

> 全量回归 + CI 质量门禁 skill。

---

## 一句话定位

**编码完成后跑全量测试** —— 自动检测技术栈，全量跑测试，输出门控信号（PASS / BLOCKED）。

---

## 何时用

| 场景 | 是否用 |
|-----|-------|
| path-a 阶段 3 编码完成 | ✅ 必做 |
| path-c bug 修复完成 | ✅ 防回归 |
| commit 前 | ✅（也会被 pre-commit hook 自动触发）|
| 怀疑某改动破坏了其他功能 | ✅ |
| 没有改代码 | ❌ |

---

## 调用方式

```bash
# 默认全量测试
/harness-test-ci

# 失败立即停（fast-fail）
/harness-test-ci --fast-fail

# 只跑变更模块的测试（不推荐 · 默认全量）
/harness-test-ci --changed-only
```

---

## 输出范例

```
🔍 检测技术栈：Python (pyproject.toml)
🔍 测试框架：pytest
⏱️  开始全量测试...

tests/test_user.py::test_create_user PASSED
tests/test_user.py::test_update_user PASSED
tests/test_order.py::test_place_order PASSED
...
tests/test_admin.py::test_admin_login FAILED
   AssertionError: expected 200, got 500

📊 测试结果

通过：24 / 25
失败：1
跳过：0
覆盖率：87% (目标 ≥ 80% ✅)

🔴 BLOCKED · 不允许 commit

失败详情：
- tests/test_admin.py::test_admin_login
  → AssertionError: expected 200, got 500
  → 推测原因：本次改了 src/auth/middleware.py
```

---

## 它做什么 / 不做什么

**做**：
- ✅ 自动检测技术栈（Python / Java / Node / Go）
- ✅ 全量跑测试 + 输出门控
- ✅ 失败时给"推测原因"（基于本次 git diff）
- ✅ 与 pre-commit hook 协作（`bash .claude/hooks/pre-commit-test.sh`）

**不做**：
- ❌ 不写测试（那是开发者的事）
- ❌ 不修代码（那是 implementer 的事）
- ❌ 不强制覆盖率（默认提示 ≥ 80%，可配置）

---

## 与 pre-commit hook 的关系

`templates/.claude/hooks/pre-commit-test.sh` 在 `git commit` 时自动调用，逻辑同 `/harness-test-ci`：
- 测试通过 → 允许 commit
- 测试失败 → 阻塞 commit + 显示原因

**主动调用 `/harness-test-ci`** vs **被动 hook 触发**：
- 主动：commit 前自检，避免被 hook 拦
- 被动：兜底（你忘了主动跑也会被拦）

---

## 决策点（v1.0.21+）

| 决策点 | 选项示例 |
|-------|---------|
| 全量 vs 增量 | 全量回归（推荐）/ 仅本次相关 |
| 失败时策略 | fast-fail / 继续跑完所有 |
| 测试报告粒度 | 简要 / 详细 / 附完整日志 |

---

## 常见问题

### Q1：测试失败但本次改动看起来无关，怎么办？
A：报告会给"推测原因"。如果确实无关 → 说明这是**已存在的 bug**（不是本次引入），可走 path-c 修。

### Q2：测试时间太长（> 5 分钟）怎么办？
A：
- 短期：用 `--changed-only` 减少跑的范围（但有漏检风险）
- 长期：让测试本身提速（mock 慢依赖 / 并行测试）

### Q3：没有测试基础设施怎么办？
A：principles §11 推荐渐进策略：
- 先建测试框架（pytest / jest 等）
- 然后修改某文件时强制为该文件加测试
- 长期累积到全覆盖

### Q4：测试通过 = 代码没问题吗？
A：**不等于**。测试通过只代表"已有测试覆盖的部分没问题"。要有信心还需要 `/harness-impact` 看影响面 + `/harness-review` 看一致性。

### Q5：能跳过测试 commit 吗？
A：紧急情况：`HARNESS_SKIP_TEST=1 git commit`。但 principles §11 明确这违反铁律——只能临时用，事后必须补测试。

---

## 与其他 skill 的协作

```
[implementer 编码完成]
   ↓
/harness-impact（影响面）
   ↓
/harness-test-ci（你在这里）
   ↓ 通过
/harness-review（一致性审计）
   ↓
commit （pre-commit hook 再跑一次）
```

---

## 进阶

- skill 定义：`.claude/skills/harness-test-ci/SKILL.md`
- pre-commit hook：`.claude/hooks/pre-commit-test.sh`
- principles §11：`.claude/rules/principles.md`

---

*Harness-Lite v1.0.21 · /harness-test-ci 用户手册*
