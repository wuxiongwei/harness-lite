# {{PROJECT_NAME}}

> **{{PROJECT_TAGLINE}}**
> 本文件是团队与AI协作的总协议入口。`/clear`后每次会话自动加载。
>
> 由 [Harness-Lite](https://github.com/zoe/harness-lite) v{{HARNESS_LITE_VERSION}} 生成 · 安装时间：{{INSTALL_DATE}}

---

## 1. 项目定位

- **业务**：{{BUSINESS_DESCRIPTION}}
- **形态**：{{PROJECT_TYPE}}
- **技术栈**：{{TECH_STACK}}
- **团队规模**：{{TEAM_SIZE}}
- **当前阶段**：{{PROJECT_STAGE}}

---

## 2. 行为准则与业务铁律（强制载入）

@.claude/rules/principles.md
@.claude/rules/tech-stack-rules.md
@.claude/rules/domain-rules.md

> 上述三份是 MUST 级约束，违反即返工。
> `principles.md` 治"AI编码通用失误"，`tech-stack-rules.md` 治"技术栈陷阱"，`domain-rules.md` 治"业务陷阱"。

---

## 3. 工作流（4阶段 + 路径分级）

### 3.1 工序总览

```
新需求来了
    ↓
[/harness:req 自动判定路径]
    ↓
┌────┼────┐
↓    ↓    ↓
A    B    C
完整  小   Bug
需求  需求  修复
4阶段 2阶段 专项流程
```

### 3.2 三条路径

| 路径 | 触发条件 | 阶段数 | 典型耗时 |
|------|---------|------|---------|
| **A 完整需求** | 新功能、独立模块、跨模块改动 | 4 | 30-90分钟 |
| **B 小需求** | 改文案、改配置、字段加减、≤3文件 | 2 | 5-15分钟 |
| **C Bug修复** | bug、异常、报错、5xx、复现 | 4 | 15-60分钟 |

### 3.3 路径A产物链路

```
01-需求.md  →  02-设计.md  →  03-代码索引.md  →  04-测试.md
   ↓             ↓               ↓                 ↓
  doc-       doc-          implementer      validator
  generator  generator       subagent         subagent
   ↓             ↓               ↓                 ↓
              reviewer
              subagent
```

**产物输出位置**：`docs/versions/active/v{X.Y}-{slug}/`

### 3.4 路径B产物链路（轻量）

```
01-小需求记录.md  →  04-验证.md
（合并需求+设计的极简版）   （含变更diff + 影响面 + 快速冒烟）
```

### 3.5 路径C产物链路（Bug修复）

```
01-复现.md  →  02-根因.md  →  03-修复.md  →  04-回归.md
   ↓             ↓             ↓             ↓
 必须可复现    定位根本原因   最小修复       回归+原场景验证
```

### 3.6 关键命令

| 命令 | 作用 | 路径 |
|-----|-----|-----|
| `/harness:req` | 入口（含路径自动判定） | A/B/C |
| `/harness:design` | 设计 | A |
| `/harness:review` | 一致性审计 | A/C |

详见：[skill手册](.claude/skills/)

---

## 4. 上下文管控协议

### 4.1 自动加载层（每次会话）

```
本文件（CLAUDE.md）
  ├── @.claude/rules/principles.md
  ├── @.claude/rules/tech-stack-rules.md
  └── @.claude/rules/domain-rules.md
```

### 4.2 按需Read层

```
- 老项目历史文档 → 需要时明确指定路径Read
- team-knowledge/wiki/ → 涉及相关知识时主动Read
- docs/versions/archive/ → 涉及历史需求时主动Read
```

### 4.3 subagent隔离层

```
跨3+文件的探索 → 必须委托给Explore subagent
独立可并行的子任务 → 委托给subagent（如多角度审查）
决策性工作 → 主上下文，不外派
```

### 4.4 主上下文纯净原则

```
✅ 主上下文承载：
  - 决策（人决策、AI决策）
  - 产物（写入文件的内容）
  - 关键引用（少量必要的代码片段）

❌ 主上下文不承载：
  - 大段搜索结果
  - 完整代码文件内容（除非要修改）
  - 不必要的上下文堆积
```

---

## 5. 团队协作约定

### 5.1 新需求处理

```
1. 接到需求 → /harness:req（自动判定路径）
2. 确认路径 → 创建版本目录 docs/versions/active/v{X.Y}-{slug}/
3. 走完产物链路（A/B/C路径）
4. 反向校验（每个阶段结束）
5. 收尾时蒸馏知识（如有踩坑/决策）
```

### 5.2 老代码维护

```
渐进迁移原则：
- 新需求强制走4阶段产物链路
- 老代码维护鼓励补文档（不强制）
- 改老代码bug时，顺手补一条pitfall到 wiki/pitfalls/
```

### 5.3 知识沉淀时机

每次需求收尾时，**强制问自己**：
- 这次有踩什么新坑吗？→ `team-knowledge/wiki/pitfalls/`
- 这次有重要技术决策吗？→ `team-knowledge/wiki/decisions/`
- 这次有新接口/契约吗？→ `team-knowledge/wiki/interfaces/`

### 5.4 hook门禁约定

```
git push → 默认拦截，必须人工确认
.env / credentials.* → 禁编辑
rm -rf → 禁执行
危险命令 → 二次确认
```

---

## 6. 反馈回路（核心质量机制）

### 6.1 4个人介入决策点

每个完整需求（路径A）必须经过4个人介入：

```
人介入1：方案确认
  位置：02-设计.md 完成后
  目的：防方向错
  人要判断：技术路线、边界、是否拆迭代

人介入2：用例评审
  位置：04-测试.md 设计阶段
  目的：防自写自批
  人要判断：P0/P1是否覆盖主链路、异常、跨入口

人介入3：Review决策
  位置：代码完成后
  目的：防严重工程缺陷
  人要判断：严重项必须修，重要项是否defer

人介入4：最终决策
  位置：04-测试.md 完成后
  目的：防误提交/误上线
  人要判断：Layer 1/2/3 报告，是否commit/上线
```

### 6.2 反向校验机制

```
写完每个阶段产物后，AI自动追问：

01-需求 → "用一句话重述这个需求"
02-设计 → "这个设计能否回答需求所有问题？有没有越界？"
03-代码 → "代码是否按设计实现？有无加未要求的功能？"
04-测试 → "测试是否覆盖需求所有验收标准？反推能回到原始需求吗？"
```

### 6.3 验收分层（Layer 1/2/3）

```
Layer 1 单元测试    ← 推荐，但不是终判
Layer 2 集成测试    ← 推荐，但不是终判  
Layer 3 E2E真实链路 ← 强烈推荐（唯一真终判）

⚠️ 单测全绿 ≠ 上线安全
⚠️ "环境问题" 不是跳过Layer 3的理由
```

---

## 7. 关键约束（红线）

以下是**绝不允许**违反的红线：

### 7.1 阻塞即停止

```
❌ 禁止：
- "代码逻辑正确，仅 DDL 缺失" → 这是阻塞，必须修
- "单测通过，E2E 环境问题不算失败" → 没Layer 3就是没验证
- "先跳过，后续上线再处理" → 不允许累积技术债
- "Layer 3 未执行但报告测试通过" → 不可伪验证

✅ 正确做法：
- 发现阻塞项 → 停止当前阶段
- 输出阻塞原因 + 解决方案
- 等待解除或授权 → 重新执行
```

### 7.2 不主动commit/push

```
❌ AI不能：
- 主动 git commit
- 主动 git push
- 主动合并分支
- 主动覆盖未提交的修改

✅ AI应该：
- 完成代码后告知用户
- 等用户明确指令后才执行git操作
```

### 7.3 敏感文件保护

```
❌ 禁止编辑/提交：
- .env / .env.local / .env.production
- credentials.* / secrets.*
- *.key / id_rsa* / *.pem
- serviceAccountKey.json

⚠️ 修改auth/login相关代码时：
- 必须明确告知用户
- 必须解释变更影响
```

### 7.4 上下文清白

```
/clear 后第一件事：重读本文件
不依赖会话记忆，规则以文件为准
```

---

## 8. 关键文档索引

### 8.1 项目层文档

| 路径 | 内容 |
|-----|-----|
| `.claude/rules/principles.md` | 行为准则（AI通用失误） |
| `.claude/rules/tech-stack-rules.md` | 技术栈约束 |
| `.claude/rules/domain-rules.md` | 业务铁律 |
| `.claude/skills/` | 主skill和subagent定义 |
| `team-knowledge/wiki/pitfalls/` | 历史陷阱 |
| `team-knowledge/wiki/decisions/` | 关键决策 |
| `docs/versions/active/` | 当前开发中的需求 |
| `docs/versions/archive/` | 已归档的历史需求 |

### 8.2 Harness-Lite产品文档

如果你想了解Harness-Lite本身，访问产品文档：
{{HARNESS_LITE_DOCS_URL}}

---

## 9. 演进维护

### 9.1 本文件维护

```
每月review一次：
- 删过期规则
- 加新踩坑反哺的规则
- 调整路径判定阈值

更新方式：
- 直接修改本文件
- 在CHANGELOG.md追加记录
```

### 9.2 升级Harness-Lite

```
$ /path/to/harness-lite/scripts/upgrade.sh

升级时本文件会保留你的"用户定制区"内容（见下）。
```

---

## 10. 用户定制区

> **以下区域是你的领地**，Harness-Lite升级时不会覆盖。
> 在这里加你团队特有的约定、备注、临时规则。

<!-- USER CUSTOMIZATION START -->

### 10.1 团队特有约定

（在此添加你团队的特殊约定）

### 10.2 临时规则

（在此添加临时性规则，比如某次活动期间的特殊要求）

### 10.3 备注

（在此添加任何备注）

<!-- USER CUSTOMIZATION END -->

---

*由 Harness-Lite v{{HARNESS_LITE_VERSION}} 生成 · 当前版本：v{{PROJECT_VERSION}} · 最后更新：{{LAST_UPDATE}}*
