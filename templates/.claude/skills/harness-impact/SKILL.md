---
name: harness-impact
description: |
  影响面分析 skill。基于 git diff 找出改动文件，
  通过 grep/import 分析扫描哪些模块依赖它们，
  输出直接/间接影响清单 + 测试覆盖情况，
  帮助 AI 和开发者知道"改了 A 会不会影响 B"。
trigger:
  keywords: ["影响面", "影响分析", "改动影响", "会不会影响"]
  patterns: ["/harness:impact", "/impact"]
version: 1.0.0
---

# /harness:impact · 影响面分析 skill

> **回答"改了什么、影响了谁"** · 辅助全量回归决策

---

## 核心价值

```
AI 改了 user_service.py
         ↓
影响面分析告诉你：
  直接调用方：user_api.py, admin_api.py
  间接依赖方：onboarding_workflow.py（依赖 user_api）
  测试覆盖：user_api.py ✅ 有测试 / onboarding ⚠️ 无直接测试
         ↓
基于此决定：需要重点关注哪些测试是否通过
```

---

## 触发时机

通常在以下两个节点调用：

```
1. 编码完成后（implementer 完成）：
   /harness:impact → 了解影响面 → /harness:test-ci（有重点跑）

2. 设计阶段（02-设计.md 的 §8 影响面分析）：
   /harness:impact --staged  ← 提前分析，指导设计
```

---

## Phase 1：获取改动文件列表

```bash
# 未提交的改动
git diff --name-only HEAD

# 已 staged 的改动
git diff --name-only --cached

# 指定 commit 的改动
git diff --name-only {commit-sha}~1 {commit-sha}
```

输出示例：
```
src/services/user_service.py
src/models/user.py
```

---

## Phase 2：依赖关系扫描

根据技术栈选择扫描策略：

### Python

```bash
# 找出谁 import 了改动文件中的模块/函数
for changed_file in $changed_files; do
    module=$(basename "$changed_file" .py)
    grep -rn "from.*$module import\|import.*$module" \
        --include="*.py" src/ tests/ \
        | grep -v "^$changed_file:"
done
```

### Java

```bash
# 找出谁 import 了改动的类
for changed_file in $changed_files; do
    class=$(basename "$changed_file" .java)
    grep -rn "import.*$class\b" \
        --include="*.java" src/ \
        | grep -v "^$changed_file:"
done
```

### Node.js / TypeScript

```bash
# 找出谁 require/import 了改动文件
for changed_file in $changed_files; do
    filename=$(basename "$changed_file" | sed 's/\.[^.]*$//')
    grep -rn "require.*$filename\|from.*$filename" \
        --include="*.{js,ts}" src/ \
        | grep -v "^$changed_file:"
done
```

---

## Phase 3：测试覆盖检测

对每个被影响的文件，检查是否有对应测试：

```bash
# Python：tests/test_xxx.py 或 tests/xxx_test.py
for affected in $affected_files; do
    base=$(basename "$affected" .py)
    has_test=false
    if find tests/ -name "test_${base}.py" -o -name "${base}_test.py" | grep -q .; then
        has_test=true
    fi
    echo "$affected | $has_test"
done
```

---

## Phase 4：报告生成

输出格式：

```markdown
# 影响面分析报告

## 本次改动文件

| 文件 | 改动类型 |
|------|---------|
| src/services/user_service.py | 修改 |
| src/models/user.py | 修改 |

## 直接依赖（调用了改动文件的模块）

| 依赖方 | 依赖内容 | 有测试？ |
|--------|---------|---------|
| src/api/user_api.py | from user_service import * | ✅ test_user_api.py |
| src/admin/user_admin.py | import user_service | ✅ test_user_admin.py |

## 间接依赖（依赖直接依赖方的模块）

| 模块 | 依赖链 | 有测试？ |
|------|-------|---------|
| src/workflows/onboarding.py | onboarding → user_api → user_service | ⚠️ 无直接测试 |

## 测试覆盖汇总

| 指标 | 数量 |
|------|------|
| 改动文件数 | 2 |
| 直接依赖方 | 2（全部有测试）|
| 间接依赖方 | 1（无直接测试）|
| 建议重点关注测试 | test_user_api.py, test_user_admin.py |

## 风险评估

🟢 **低风险**：所有直接依赖都有测试覆盖
⚠️ **注意点**：onboarding_workflow.py 无直接测试，但通过集成测试覆盖

## 建议

1. 全量测试时，重点关注以下测试是否通过：
   - tests/test_user_api.py
   - tests/test_user_admin.py
2. 如果集成测试覆盖了 onboarding，则风险可控
3. 建议为 onboarding_workflow.py 补充单测（渐进策略）
```

---

## Phase 5：与 /harness:test-ci 协作

影响面分析的输出，可以给 `/harness:test-ci` 提供"重点关注清单"：

```
/harness:impact → 识别高风险文件
    ↓
/harness:test-ci --focus=test_user_api.py,test_user_admin.py
    ↓
全量跑完后，重点展示这几个文件的结果
```

---

## 使用示例

```
用户：/harness:impact

skill 行动：
  Phase 1：git diff HEAD → 发现 2 个改动文件
  Phase 2：扫描 import → 找到 2 个直接依赖、1 个间接依赖
  Phase 3：检查测试 → 2 有测试，1 无直接测试
  Phase 4：输出影响面报告

输出：
  📊 影响面摘要：
    改动：2 个文件
    直接依赖：2 个（全部有测试 ✅）
    间接依赖：1 个（无直接测试 ⚠️）
    
  🎯 建议重点关注：test_user_api.py, test_user_admin.py
  
  → 运行 /harness:test-ci 开始全量验证
```

---

## 局限性

1. **静态分析，不是运行时分析**：动态注入/反射等场景无法识别
2. **依赖深度默认2层**：超过2层的间接依赖不分析（避免噪音）
3. **非代码依赖不覆盖**：SQL/配置文件/环境变量等依赖需人工补充
4. **测试文件命名依赖约定**：test_xxx.py 或 xxx_test.py 才能识别

---

## 与 03-代码索引.md 的关系

`/harness:impact` 的输出可以直接填入 `03-代码索引.md §5 影响面`：

```markdown
## 5. 影响面（来自 /harness:impact）
（粘贴影响面报告的摘要）
```

这让影响面分析从"手工填写"升级为"工具辅助生成"。

---

*Harness-Lite v1.0.0 · /harness:impact · 影响面分析*
