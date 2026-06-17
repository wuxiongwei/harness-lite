---
name: harness-design
description: |
  设计阶段 skill。基于 01-需求.md 生成 02-设计.md（技术方案/关键决策/影响面），
  委托 doc-generator 起草、reviewer 独立评审。仅路径 A 使用。
  典型触发：用户说"设计方案"、"技术方案"、"架构设计"，或刚做完 /harness-req 进入第二阶段。
---

# /harness-design · 设计阶段 skill

> **路径A · 阶段2/5**：把需求翻译为技术方案

---

## 触发条件

- 路径A的01-需求.md 已通过（人介入1：方案确认）
- 用户主动调用：`/harness-design`

---

## Phase 1：上下文加载

```
1. 强制Read：当前版本目录的 01-需求.md
2. 按需Read：
   - team-knowledge/wiki/decisions/ （查相关历史决策）
   - team-knowledge/wiki/architecture/ （查相关架构）
3. 主上下文只承载关键信息
```

---

## Phase 2：模板加载

```
强制Read：.claude/templates/path-a/02-设计.md
```

模板缺失 → 立即停止，报错。

---

## Phase 3：subagent 调度

### Step 1：doc-generator 起草

```
Task(
  subagent_type: "doc-generator",
  description: "基于01-需求起草02-设计",
  prompt: """
    基于 docs/versions/active/v{X}-{slug}/01-需求.md，
    按照 .claude/templates/path-a/02-设计.md 的结构起草设计文档。
    
    严格要求：
    1. 每个决策点必须给出 2-3 个候选方案 + 优劣对比 + 选择原因
    2. 不允许"我觉得 X 更好"这种主观判断（必须有客观依据）
    3. 边界场景必须对应01-需求的边界场景，给出具体处理方案
    4. "不做的范围"承接01-需求 + 设计层面再次明确
    5. 所有决策能追溯到01-需求的某节
    
    禁止：
    - 不读 src/main 业务代码（黑盒视角）
    - 不为不可能的场景设计错误处理
    - 不引入未要求的功能（不超出01-需求范围）
  """
)
```

### Step 2：reviewer 独立评审

```
Task(
  subagent_type: "reviewer",
  description: "独立评审02-设计",
  prompt: """
    独立 review 02-设计.md，对照01-需求.md：
    
    评审重点：
    1. 设计是否完整覆盖01-需求所有 AC？
    2. 设计是否越界（做了01-需求没要求的事）？
    3. 决策选择是否合理（候选对比是否充分）？
    4. 边界场景处理是否到位？
    5. 影响面评估是否准确？
    
    输出：
    - 🟢 PASS / 🟡 REVISION / 🔴 BLOCKED
    - 具体问题清单（如有）
    
    严格要求：
    - 不读 doc-generator 的思路（防锚定）
    - 独立从01-需求出发推导，对照设计稿
  """
)
```

---

## Phase 4：反向校验追问

doc-generator 完成后，主 skill 追问：

```
1. "请用一句话总结这次设计的核心方案"
2. "01-需求 §X.Y 的验收标准，对应设计的哪一节？"
3. "设计有越界吗？做了 01-需求 没要求的事吗？"
4. "边界场景全覆盖了吗？逐条确认"
```

---

## Phase 5：铁律自检

```
[ ] 1. 反向校验四项全部Yes
[ ] 2. 决策追溯清晰（每条 ← 01-需求 §X.Y）
[ ] 3. 候选方案对比充分（≥2个）
[ ] 4. 边界场景对应01-需求边界
[ ] 5. 影响面已评估
[ ] 6. "不做的范围"明确
[ ] 7. 门控信号区已填写
```

---

## Phase 6：流转建议

```
✅ reviewer 给出 🟢 PASS：
   → 提示用户进入"人介入1：方案确认"
   → 用户确认后，进入编码（implementer subagent）

🟡 reviewer 给出 🟡 REVISION：
   → 列出问题清单
   → 委托 doc-generator 修订
   → 重新评审（最多3轮）

🔴 reviewer 给出 🔴 BLOCKED：
   → 输出阻塞原因
   → 等待人介入
```

---

## 与 implementer subagent 协作

设计通过后，由 implementer 进入编码：

```
Task(
  subagent_type: "implementer",
  description: "按设计稿编码",
  prompt: """
    严格按照02-设计.md 实现：
    1. 不允许加设计没说的功能
    2. 不主动重构邻近代码
    3. 边写边维护03-代码索引.md
    4. 不主动 git commit
    5. 完成后委托 code-reviewer 独立审查
  """
)
```

---

## 错误处理

### 01-需求 不存在
```
报错："请先完成 /harness-req 阶段"
```

### 01-需求 未通过（状态不是 🟢）
```
报错："01-需求 状态为 X，必须 🟢 才能进入设计阶段"
```

### 设计反复修订（>3轮）
```
报错："设计反复修订超过3轮，可能需求理解有问题"
建议：回到 /harness-req 重新审视01-需求
```

---

## 使用示例

```
用户：/harness-design

skill 行动：
  1. 加载 01-需求.md
  2. 加载 02-设计.md 模板
  3. 委托 doc-generator 起草
  4. 委托 reviewer 评审
  5. 反向校验
  6. 提示用户：方案已就绪，请进入"人介入1：方案确认"
```

---

*Harness-Lite v1.0.0-alpha · /harness-design · 路径A 阶段2*
