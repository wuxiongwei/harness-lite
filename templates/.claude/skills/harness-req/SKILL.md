---
name: harness-req
description: |
  Harness-Lite 主入口。当用户描述新需求 / 改文案 / 修 bug 时调用，
  自动判定路径（A 完整需求 / B 小需求 / C Bug 修复），生成第一阶段产物。
  典型触发：用户说"新需求"、"改个 X"、"加一个 X"、"修复 bug"、"改文案"、"调配置"、"新增功能"、"TDD"。
---

# /harness-req · 主入口 skill

> **路径分级 + 第一阶段产物生成**
> 这是 Harness-Lite 的统一入口，所有需求都从这里开始

---

## Phase 1：场景判定（路径自动选择）

### 判定流程

```
用户输入需求
    ↓
① 含 bug / 异常 / 报错 / 5xx / 复现 / 修复？
    ├─ 是 → 路径 C（Bug 修复）
    └─ 否 → 进入 ②
        ↓
② 改文案 / 改配置 / 字段微调 / 改样式？
   且预估改动 ≤ 3 文件？
   且不改接口/数据结构？
    ├─ 是 → 路径 B（小需求）
    └─ 否 → 进入 ③
        ↓
③ 新增功能 / 独立模块 / 跨工程？
    ├─ 是 → 路径 A（完整需求）
    └─ 不确定 → 询问用户确认
```

### 判定关键词

#### 路径 C 触发词
- 中文：bug、异常、报错、错误、500、404、复现、修复、定位、出问题、不工作、挂了、崩了
- 英文：bug, error, exception, fail, broken, crash, fix, debug, reproduce

#### 路径 B 触发词
- 中文：改文案、改文字、调样式、调配置、加字段、改字段、加枚举、调超时
- 英文：tweak, adjust, change text, update config, rename

#### 路径 A 触发词
- 中文：新增、新功能、新模块、独立功能、TDD、写测试
- 英文：add feature, new module, implement, build

#### 不确定时
向用户列出 2-3 个候选路径让用户选，不要静默猜。

---

## Phase 2：路径执行

### 路径 A 执行（完整需求 5 阶段）

```
1. 创建版本目录：docs/versions/active/v{X.Y}-{slug}/
2. 复制模板：cp .claude/templates/path-a/01-需求.md ./
3. 委托 doc-generator subagent 填充 01-需求.md（黑盒视角）
4. 委托 reviewer subagent 独立评审 01-需求.md
5. 反向校验追问：
   - "用一句话重述这个需求"
   - "AC是否覆盖主流程+异常?"
   - "不做的范围是否明确?"
6. 等待"人介入1：方案确认"
7. ✅ 通过后 → 进入 /harness-design
```

### 路径 B 执行（小需求 2 阶段）

```
1. 验证路径B硬规则：
   - 改动文件数预计 ≤ 3
   - 不改接口签名
   - 不改数据结构
   不满足 → 升级路径A
2. 创建版本目录
3. 复制模板：cp .claude/templates/path-b/01-小需求.md ./
4. 直接填充（不需要subagent）
5. 反向校验追问
6. ✅ 通过后 → 进入 /harness-design 或直接编码
```

### 路径 C 执行（Bug 修复 4 阶段）

```
1. 创建版本目录
2. 复制模板：cp .claude/templates/path-c/01-复现.md ./
3. 委托 doc-generator subagent 填充复现步骤
4. 关键检查：
   - bug能稳定复现吗？
   - 失败回归测试已写并验证为RED吗？
   - 同类入口已检查吗？
5. 反向校验追问
6. ✅ 通过后 → 进入 02-根因.md
```

---

## Phase 3：subagent 调度

主 skill 必须用 Task 工具调度 subagent，不能自己写产物：

```
Task(
  subagent_type: "doc-generator",
  description: "填充01-需求.md",
  prompt: "..."
)
```

每个 subagent 严格限定可见范围（防自写自批）：

| Subagent | 可读 | 不可读 |
|----------|-----|-------|
| doc-generator | 用户输入、模板、需求规格 | src/main 业务代码 |
| reviewer | 用户输入、产物文件 | doc-generator 的产出过程 |
| implementer | 设计文档、失败测试 | 自己编写测试 |
| validator | 测试用例、产物 | 实现细节 |

---

## Phase 4：模板加载

```
路径A：
  - .claude/templates/path-a/01-需求.md
  
路径B：
  - .claude/templates/path-b/01-小需求.md
  
路径C：
  - .claude/templates/path-c/01-复现.md
```

⚠️ 模板缺失即停止：报错并提示用户重新安装

---

## Phase 5：铁律自检

在产物完成前，subagent 必须自检以下7项：

```
[ ] 1. 用户原话被准确引用（不是二次加工）
[ ] 2. 验收标准 ≥ 3条且包含异常场景
[ ] 3. "不做的范围"明确写出
[ ] 4. 待确认问题已列出（不能静默猜）
[ ] 5. 影响面已评估
[ ] 6. 反向校验四项全部Yes
[ ] 7. 门控信号区已填写
```

---

## Phase 5.5：决策点处理（v1.0.21+ · principles §13）

本 Phase 在 Phase 4 模板加载后、Phase 5 铁律自检前执行。

### 遇到决策点时

"决策点" = 有 ≥ 2 个合理选项的子问题需要拍板（如用户故事粒度、AC 数量、排序方式等）。

**处理流程**：

1. **提取场景关键词**（3-5 个）：当前阶段（path-a/01-需求）、决策类型、上下文。

2. **查询自决清单**：
   ```
   Read .claude/auto-decide.md
   严格匹配：所有关键词都命中某条？
   ```

3. **命中 → 自决**：
   - 使用该条"自动选择"的值
   - 在主产物（01-需求.md）末尾追加标注：
     ```markdown
     ---
     > ℹ️ 本产物已使用 AI 自决项：
     >   - {决策标题}：{选择}（撤回：编辑 .claude/auto-decide.md）
     ```

4. **未命中 → 询问用户**：
   ```
   🤔 {问题}
      [1] 选项 A
      [2] 选项 B
      [3] 选项 C
   
   请选择 [1/2/3]：
   ```

5. **用户答后 → 记录日志**：
   追加到 `.claude/decision-log.md`：
   ```markdown
   ## YYYY-MM-DD HH:MM · {版本ID} · path-a/01-需求 · {简短标题}
   - 问题：{完整问句}
   - 选项：[A / B / C]
   - 用户答：{选中}
   - 关键词：{kw1, kw2, kw3}
   - 状态：⏳ 待复盘
   ```

### 典型决策点（harness-req）

- 用户故事粒度（粗 vs 细）
- AC（验收标准）数量（每 US 几条）
- 需求排序（按优先级 vs 按阶段 vs 按模块）
- 不做范围是否独立章节
- 技术约束章节粒度

### 向下兼容

如 `.claude/auto-decide.md` 不存在 → 直接询问（等同 v1.0.20 行为）。

---

## Phase 6：流转建议

```
✅ PASS    → 进入下一阶段
🟡 REVISION → 修订当前产物
🔴 BLOCKED → 输出阻塞原因，等待人介入
```

---

## 错误处理

### 用户输入太模糊
```
❌ 不要：自己脑补需求
✅ 要：列出 2-3 种解读，让用户选
```

### 用户未选择路径
```
❌ 不要：静默选一个路径
✅ 要：向用户解释 A/B/C 的差异，让用户确认
```

### 模板文件缺失
```
❌ 不要：自己生成模板
✅ 要：报错"模板缺失，请重新安装 Harness-Lite"
```

---

## 使用示例

### 示例1：完整需求

```
用户：/harness-req 新增用户中心，支持手机号注册、登录、找回密码

skill 判定：
  - 含"新增" → 路径A候选
  - 含"独立功能" → 确认路径A
  
skill 行动：
  1. 创建 docs/versions/active/v1.1-用户中心/
  2. 复制 path-a/01-需求.md
  3. 委托 doc-generator 填充
  4. 反向校验
  5. 提示人介入1：方案确认
```

### 示例2：小需求

```
用户：/harness-req 把订单超时时间从30分钟改成1小时

skill 判定：
  - 含"改" + 配置 → 路径B候选
  - 改动文件预估 ≤ 1 → 确认路径B

skill 行动：
  1. 创建版本目录
  2. 复制 path-b/01-小需求.md
  3. 直接填充
  4. 验证路径B硬规则
  5. ✅ 通过 → 进入实施
```

### 示例3：Bug修复

```
用户：/harness-req 用户提现接口返回500，复现：金额输入小数点后3位

skill 判定：
  - 含"500" + "复现" → 路径C
  
skill 行动：
  1. 创建版本目录
  2. 复制 path-c/01-复现.md
  3. 委托 doc-generator 填充复现步骤
  4. 强制要求："请提供 RED 测试"
  5. 等待用户提供后进入 02-根因
```

---

## 与其他 skill 的协作

```
/harness-req → 完成01产物
   ↓
/harness-design → 完成02产物（路径A/C走）
   ↓
[implementer subagent] → 编码 + 03产物
   ↓
/harness-review → 一致性审计
   ↓
[validator subagent] → 完成04产物
```

---

*Harness-Lite v1.0.0-alpha · /harness-req · 主入口*
