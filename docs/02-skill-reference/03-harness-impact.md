# `/harness-impact` 用户手册

> 影响面分析 skill · 回答"改了 A 会不会影响 B"。

---

## 一句话定位

**编码完成后、commit 前**调用 —— 基于 git diff 找出改动文件，扫描依赖，输出影响清单 + 测试覆盖。

---

## 何时用

| 场景 | 是否用 |
|-----|-------|
| path-a 阶段 3 编码完成 | ✅ commit 前必做 |
| path-c bug 修复完成 | ✅ 防回归 |
| 想知道改动牵动哪些其他模块 | ✅ |
| 改动很小（单文件、独立模块） | 🟡 可选（影响面小，目测即可） |
| 还没编码 / 设计阶段 | ❌ 这时用 02-设计.md §影响面 |

---

## 调用方式

```bash
# 默认分析当前 git diff（未 staged 改动）
/harness-impact

# 分析已 staged 改动
/harness-impact --staged

# 分析某个 commit
/harness-impact --commit=abc1234
```

---

## 输出范例

```
📊 影响面分析报告

## 本次改动文件（3 个）

| 文件 | 改动类型 | 行数 |
|------|---------|------|
| src/services/user_service.py | 修改 | +20/-5 |
| src/models/user.py | 修改 | +3/-0 |
| tests/test_user_service.py | 修改 | +15/-0 |

## 直接依赖（调用了改动文件的模块）

| 依赖方 | 依赖内容 | 有测试？ |
|--------|---------|---------|
| src/api/user_api.py | from user_service import * | ✅ test_user_api.py |
| src/admin/user_admin.py | import user_service | ✅ test_user_admin.py |

## 间接依赖（链式调用）

| 模块 | 依赖链 | 有测试？ |
|------|-------|---------|
| src/workflows/onboarding.py | onboarding → user_api → user_service | ⚠️ 无直接测试 |

## 风险评估

🟢 低风险：所有直接依赖都有测试覆盖
⚠️ 注意：onboarding_workflow.py 需通过集成测试覆盖

## 建议

1. 全量测试时重点关注：
   - tests/test_user_api.py
   - tests/test_user_admin.py
2. 建议为 onboarding_workflow.py 补单测（渐进策略）
```

---

## 它做什么 / 不做什么

**做**：
- ✅ 静态扫描（grep import / require / from）
- ✅ 分析直接依赖 + 间接依赖（默认 2 层）
- ✅ 检测测试覆盖（test_*.py / *_test.py 命名规约）
- ✅ 输出 markdown 报告（可直接贴 03-代码索引.md §影响面）

**不做**：
- ❌ 动态分析（运行时反射 / 注入）
- ❌ 跨语言追溯（如 Python 调 C 扩展）
- ❌ 数据库 schema 影响（只看代码层）
- ❌ 配置文件影响（除非显式查找）

---

## 决策点（v1.0.21+）

| 决策点 | 选项示例 |
|-------|---------|
| 影响范围深度 | 仅直接依赖 / 间接 1 层 / 间接 2 层 |
| 报告格式 | 树状 / 表格 / Mermaid 图 |
| 回归测试粒度 | 全量 / 仅影响模块 |

---

## 常见问题

### Q1：影响面太大怎么办？
A：**反向校验需求边界**——是不是需求自身偏大？建议拆分为多个小迭代。

### Q2：报告显示某模块"无直接测试"，必须补吗？
A：看是否在关键路径。`principles.md §11 全量回归铁律` 推荐"AI 修改某文件 → 该文件必须有对应测试"——但渐进策略允许逐步补。

### Q3：能集成到 git pre-commit 吗？
A：**当前不集成**（避免阻塞）。但可以让 AI 在 commit 前主动调用一次。

### Q4：报告输出位置？
A：默认在对话中。也可写入 03-代码索引.md §影响面（`/harness-impact --output=docs/versions/active/v0.x/03-代码索引.md`）。

---

## 与其他 skill 的协作

```
[implementer 编码完成]
   ↓
/harness-impact（你在这里）
   ↓
/harness-test-ci（针对影响面跑全量测试）
   ↓
/harness-review（一致性审计）
   ↓
commit
```

---

## 进阶

- skill 定义：`.claude/skills/harness-impact/SKILL.md`
- 03-代码索引.md 模板：`.claude/templates/path-a/03-代码索引.md`

---

*Harness-Lite v1.0.21 · /harness-impact 用户手册*
