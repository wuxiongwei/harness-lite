# Skill description 字段格式约定

> 来源：Harness-Lite v1.0.7 修 skill/agent frontmatter schema 时发现

---

## 接口定义

`.claude/skills/*/SKILL.md` 和 `.claude/agents/*.md` 中的 frontmatter `description` 字段：

```yaml
---
name: harness-req
description: >
  根据用户需求自动选择路径（A完整需求/B小需求/C Bug修复），
  生成结构化产物，隔离4个subagent防自写自批
---
```

## 格式要求

| 维度 | 约束 | 理由 |
|-----|------|------|
| **长度** | 1-3 句话，≤200 字符 | Claude 模型选用 skill 时只看前 200 字符 |
| **语气** | 动词开头、陈述句 | "根据..."/"生成..."/"分析..." |
| **信息密度** | 包含**触发场景 + 核心能力** | 让 Claude 判断是否命中 |
| **禁止** | 不含 emoji、不含"本 skill"自指 | 纯文本、直接说能力 |

## 反例 vs 正例

```yaml
# ❌ 反例 1：太长
description: >
  这是一个非常强大的需求分析工具，它可以帮助你自动识别用户输入的需求类型，
  并根据不同的类型自动选择合适的处理路径，同时还会生成详细的文档...

# ❌ 反例 2：太短 + 不说触发场景
description: 需求处理

# ✅ 正例
description: >
  根据用户需求自动选择路径（A完整需求/B小需求/C Bug修复），
  生成结构化产物，隔离4个subagent防自写自批
```

## 验证方法

Harness-Lite v1.0.7 起，`scripts/validate.sh` 会检查：
- description 字段存在
- 长度在合理范围（非空、≤300 字符）

## 命中率反馈（待 v1.1）

backlog 已加"Skill 自动触发命中率统计"——未来能看到每个 skill 的 `description` 写得好不好。

---

*记录日期：2026-06-17*  
*适用范围：所有 skill / agent 定义*  
*关联：validate.sh / skill 调用机制*
