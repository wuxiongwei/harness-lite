---
name: pitfall-sed-delimiter-conflict
description: sed 分隔符与替换值字符冲突导致 "bad flag" 错误
type: pitfall
tags: [bash, sed, shell-scripting, init-script]
date: 2026-06-12
related: [[init-sh-design]]
---

# 陷阱：sed 分隔符与替换值字符冲突

> **来源**：v1.0.1-fix-init-bugs · init.sh dogfooding
> **归档时间**：2026-06-12
> **关联需求**：v1.0.1-fix-init-bugs

---

## 1. 触发场景

在 Bash 脚本中使用 sed 做模板变量替换时，**同时出现以下条件**：

```
A. sed 分隔符使用 | （非默认 /）
B. 替换值（变量值）中含有 | 字符
C. 试图用 \\\\| 转义但失败
```

**具体场景**：在 init.sh 中渲染 CLAUDE.md 模板时，要把 `{{TECH_STACK}}` 替换为 `Java | Vue | MySQL` 这样的 Markdown 表格分隔符串：

```bash
# ❌ 错误代码
sed -e "s|{{TECH_STACK}}|$BACKEND \\\\| $FRONTEND \\\\| $DATABASE|g" file
#         ↑ 分隔符 ↑                ↑ 替换值含 | ↑
```

**报错**：
```
sed: 1: "s|{{TECH_STACK}}|...": bad flag in substitute command: '�'
```

---

## 2. 根因分析

### 2.1 表层原因

`\\\\` 在 shell 双引号中被解释为 `\\`（2个反斜杠），sed 再解释为 `\`（1个反斜杠）。但 sed 分隔符是 `|`，于是 `\|` 被当成"转义的字面量 `|`"——可这一步并不能阻止 sed 把后面的 `|` 当成分隔符结束。

### 2.2 底层原因

sed 的 **s 命令的分隔符必须在替换值中转义**，但转义层次太多（shell + sed），错一层就崩。

### 2.3 设计/流程缺陷（Why-Why）

写 sed 时同时做了两件事，违反了工程经验："**sed 分隔符要选不会出现在替换值中的字符**"。

---

## 3. 后果与影响

- **用户影响**：所有首次安装的用户，init.sh 在 Step 5 崩溃
- **系统影响**：CLAUDE.md 不能正确渲染，剩余步骤跳过
- **修复成本**：发现 1 小时，修复 5 分钟（但复现+定位耗时）

---

## 4. 修复方式

### Before（错误写法）

```bash
sed -e "s|{{TECH_STACK}}|$BACKEND \\\\| $FRONTEND \\\\| $DATABASE|g" file
```

### After（正确写法）

```bash
# 1. 选不会出现在替换值中的分隔符（# 通常更安全）
# 2. 替换值的 | 改用 / （Markdown 表格也接受）
local tech_stack_str="$BACKEND / $FRONTEND / $DATABASE"
sed -e "s#{{TECH_STACK}}#$tech_stack_str#g" file
```

### 关键差异

- 分隔符：`|` → `#`
- 替换值：`|` → `/`
- 不再需要双重转义

---

## 5. 预防规则

### 5.1 是否进 CLAUDE.md 规则？

- [x] 通用 Bash 编码 → 加到 `tech-stack-rules.md`（如果项目用 Bash）

### 5.2 建议规则条款

```markdown
### Bash sed 替换的安全模式
- **要求**：sed s 命令的分隔符必须不出现在 pattern 和 replacement 中
- **检查点**：所有 `sed -e "s/.../..../g"` 调用
- **示例**：
  ```bash
  # ❌ 危险：分隔符 | 与替换值中的 | 冲突
  sed -e "s|{{KEY}}|val \\\\| with pipe|g" file
  
  # ✅ 安全：选不会出现在替换值中的分隔符
  sed -e "s#{{KEY}}#val | with pipe#g" file
  ```
- **常用安全分隔符**：`#` `,` `:` `@` `~`（按替换值内容选）
```

### 5.3 是否需要 Code Review 检查清单？

- [x] 是 → CR 时检查所有 sed 调用是否有分隔符冲突风险

### 5.4 自动化检查

未来可加 lint：grep 所有 sed 命令，检查是否有"分隔符等于替换值字符"的模式。

---

## 6. 团队同步

- [x] 已记入产品 backlog/feedback.md
- [x] 已加入 v1.0.1 修复

---

## 7. 类似问题排查

| 文件位置 | 是否有同样问题 | 处理 |
|---------|-------------|------|
| init.sh CLAUDE.md 渲染 | 有 | 已修（分隔符 #） |
| init.sh tech-stack-rules 渲染 | 已用 # 分隔符 | 无问题 |
| init.sh settings.json 渲染 | 已用 # 分隔符 | 无问题 |

---

## 关联

- 关联代码：`scripts/init.sh` render_template_vars 函数
- 关联陷阱：[[bash-local-variable-scope]]（dogfooding 同期发现）
- 关联文档：`docs/versions/active/v1.0.1-fix-init-bugs/`
