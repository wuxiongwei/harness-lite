# `/harness-req` 用户手册

> Harness-Lite 主入口 skill。需求收集与路径分流。

---

## 一句话定位

**任何新需求 / 改文案 / 修 bug 的入口** —— AI 自动判定路径（A/B/C），生成第一阶段产物。

---

## 何时用

| 场景 | 是否用 |
|-----|-------|
| 加新功能（独立模块、≥1 天工作量） | ✅ 自动判定 → path-a 完整需求 |
| 改个文案 / 调超时 / 改字段（≤3 文件） | ✅ 自动判定 → path-b 小需求 |
| 修 bug / 复现异常 | ✅ 自动判定 → path-c bug 修复 |
| 不确定走哪条路径 | ✅ 它会替你判定 |
| 已经知道走哪条路径 | ✅ 也行（明确提示） |
| 不需要结构化产物的对话 | ❌ 直接和 AI 对话即可 |

---

## 调用方式

```bash
# 1. 自然描述需求（推荐）
/harness-req 加一个搜索功能，支持按用户名 / 邮箱 / 手机号搜
/harness-req 改下登录失败提示文案
/harness-req 用户提现接口偶尔返回 500，复现：金额输入小数点后 3 位

# 2. 明确指定路径（高级）
/harness-req --path=a 完整需求描述
/harness-req --path=b 小改动描述
/harness-req --path=c bug 描述
```

---

## 输出范例

### path-a（完整需求）

```
✅ 路径判定：A 完整需求（5 阶段）
✅ 创建版本目录：docs/versions/active/v0.x-搜索功能/
✅ 已生成 01-需求.md
   - 用户故事 4 个
   - AC 12 条
   - 不做范围 5 项
   - 待确认问题 3 个

⏳ 等待人介入 1：方案确认
   你确认后，进入阶段 2 设计
```

### path-b（小需求）

```
✅ 路径判定：B 小需求（2 阶段）
✅ 创建版本目录：docs/versions/active/v0.x-超时-30到60/
✅ 已生成 01-小需求.md
   - 改动文件预估：1
   - 影响面：✅ 通过（不动接口、不动数据结构）

⏳ 你确认后直接实施
```

### path-c（bug 修复）

```
✅ 路径判定：C Bug 修复（4 阶段）
✅ 创建版本目录：docs/versions/active/v0.x-提现-500/
✅ 已生成 01-复现.md
   - 复现路径：金额 = 0.001
   - RED 测试：⏳ 等你提供
```

---

## 决策点（v1.0.21+）

调用 `/harness-req` 期间 AI 可能问你：

| 决策点 | 何时问 | 选项示例 |
|-------|-------|---------|
| 用户故事粒度 | 写 path-a/01-需求 时 | 粗 / 细 / 中等 |
| AC 数量 | 同上 | 每 US 3 条 / 5 条 / 不限 |
| 不做范围位置 | 同上 | 独立章节 / 嵌入用户故事 |
| 路径判定置信度低 | path 介于 A/B 之间 | 升级 A / 走 B 试试 |

> 对照"决策学习协议"——AI 会记录你的回答，下次同场景可批量授权。详见 `00-decision-learning-guide.md`。

---

## 常见问题

### Q1：我说"加搜索功能"它判 path-a，但我觉得是 path-b？
A：你可以反对："这个改动只动一个查询接口，路径 b"。AI 会重新判定。

### Q2：路径 B 写完了想升级到 A？
A：在 01-小需求.md 中标 `🔴 升级路径A`，AI 会重新走 5 阶段。

### Q3：path-c bug 修复时一定要 RED 测试吗？
A：**强烈推荐**（principles §11 全量回归铁律）。如果项目无测试基础设施，先补再修。

### Q4：我想跳过路径判定，直接进 path-a？
A：`/harness-req --path=a 你的需求`。

### Q5：第一阶段产物不满意，重写？
A：直接说"重写 01-需求.md，重点强调 X"。AI 会更新文件而不是新建。

---

## 与其他 skill 的协作

```
/harness-req（你在这里）
   ↓ path-a 通过
/harness-design（写 02-设计.md）
   ↓ 编码完成
/harness-impact（影响面分析）
   ↓
/harness-test-ci（全量测试）
   ↓
/harness-review（一致性审计）
   ↓
05-完成.md
```

path-b 和 path-c 流程不同，参考各自模板。

---

## 进阶

- skill 完整定义：`.claude/skills/harness-req/SKILL.md`
- 决策学习协议：`docs/02-skill-reference/00-decision-learning-guide.md`
- 路径选择硬规则：`.claude/templates/path-{a,b,c}/01-*.md` 头部"硬规则"段

---

*Harness-Lite v1.0.21 · /harness-req 用户手册*
