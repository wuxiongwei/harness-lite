# Harness-Lite（产品自身仓库）

> **AI协作工程化框架·小团队版** · 让2-5人小团队也能享受工程化红利
> 本文件是 Harness-Lite **产品自身**的协议文件（dogfooding · 自己用自己的产品）
>
> ⚠️ 注意：本文件不是产品提供给用户的 CLAUDE.md，那个在 `templates/CLAUDE.md`

---

## 1. 项目定位

- **业务**：Harness-Lite 产品本身的开发
- **形态**：仓库模板 + 智能初始化脚本 + 完整文档站
- **技术栈**：Bash（init.sh）+ Markdown（文档）+ JSON（settings）
- **团队规模**：1人主导（产品作者）+ 未来贡献者
- **当前阶段**：v1.0.0-alpha（MVP开发中，dogfooding 阶段）

### 特殊性说明

Harness-Lite **既是产品，也是产品的第一个用户**。

```
templates/.claude/    ← 给用户的模板（产品的"分发源"）
       │
       └─→ symbolic link
              │
              ↓
        .claude/      ← 自己用的（dogfooding · 与templates保持完全一致）
```

修改 `templates/.claude/` 会自动反映到 `.claude/`，单一来源不会不一致。

---

## 2. 行为准则与业务铁律（强制载入）

@.claude/rules/principles.md
@.claude/rules/tech-stack-rules.md
@.claude/rules/domain-rules.md

> 我们自己也遵守自己定的规则，违反即返工。

---

## 3. 工作流（4阶段 + 路径分级）

Harness-Lite 自身的开发**也走** 4 阶段产物链路。

### 路径选择

| 任务类型 | 路径 | 例 |
|---------|-----|-----|
| 新增 skill / 新增 agent / 重大特性 | A（完整需求） | 增加 upgrade.sh / 增加 manifest.json |
| 改 bash 一个变量 / 改文档错别字 / 调脚本提示 | B（小需求） | 修 sed 转义 / 改 banner 文案 |
| 安装/卸载脚本异常 / 模板渲染错误 | C（Bug修复） | 修 init.sh sed bug |

### 产物输出位置

```
docs/versions/active/v{X.Y.Z}-{slug}/
├── 01-需求.md
├── 02-设计.md（路径A才有）
├── 03-代码索引.md
└── 04-测试.md
```

例如：`docs/versions/active/v1.0.1-fix-init-sed-bug/`

---

## 4. 上下文管控协议

### 自动加载层
- 本文件（CLAUDE.md）
- @.claude/rules/* （3份规则）

### 按需 Read 层
- `templates/` 下所有文件 → 修改产品本身时
- `docs/00-product-spec/` → 涉及产品定位决策时
- `examples/` → 涉及示例项目时

### subagent 隔离

按 `.claude/agents/` 中定义的 4 个 subagent 调度：
- doc-generator：写需求/设计文档
- reviewer：独立评审
- implementer：编码实现
- validator：测试验证

---

## 5. Harness-Lite 特有的开发约定

### 5.1 templates/ 与 .claude/ 同步铁律

```
✅ 修改 templates/.claude/* 后，无需手动同步（符号链接）
✅ 修改 templates/CLAUDE.md（用户模板），不会影响本文件（自用版）

⚠️ 但如果在 .claude/ 上修改（实际是修改 templates/.claude/）
   → 会同时影响所有用户安装！必须谨慎
```

### 5.2 版本号约定

```
1.0.0 → 1.0.x：bug 修复（PATCH，向后兼容）
1.0.0 → 1.x.0：新功能（MINOR，向后兼容）
1.x.0 → x.0.0：破坏性变更（MAJOR，需迁移工具）
```

每次版本变化更新：
- VERSION 文件
- CHANGELOG.md
- backlog/proposals.md（如新功能源自提议）

### 5.3 产品自身的 4 阶段产物

每个版本（哪怕只是修个 bug）都建议走完整产物链路：

```
v1.0.1-fix-init-sed-bug/
├── 01-需求.md       ← 描述要修什么bug
├── 02-设计.md       ← 描述修复方案（可省略，路径B）
├── 03-代码索引.md   ← 改了init.sh的哪几行
└── 04-测试.md       ← 重测 /tmp/harness-test 验证
```

这就是最强的自证：**自己开发产品时也用产品的方法论**。

---

## 6. 反馈回路（核心质量机制）

### 4个人介入点（按需触发）

由于产品作者一人开发，4个介入点合并为：
1. **方案确认** = 我自己看02-设计是否合理
2. **用例评审** = 我自己确认04-测试覆盖
3. **Review决策** = 我自己（或独立subagent）审代码
4. **最终决策** = commit/tag前的最后核对

### 反向校验

每阶段结束自问：
```
01-需求 → "用一句话重述这个需求"
02-设计 → "这个设计能否回答需求所有问题？有没有越界？"
03-代码 → "代码是否按设计实现？有无加未要求的功能？"
04-测试 → "测试是否覆盖需求所有验收标准？反推能回到原始需求吗？"
```

### 验收分层（产品本身的特殊处理）

```
Layer 1 单元测试 → 不直接适用（产品是Bash+MD）
Layer 2 集成测试 → 用 /tmp/harness-test 跑 init.sh
Layer 3 E2E真实链路 → 在真实项目（如 stock_make_money）安装并跑通真实需求
```

⚠️ Layer 3 才是 harness-lite 的真验收标准。**stock_make_money 试用就是 Layer 3**。

---

## 7. 关键约束（红线）

### 7.1 阻塞即停止

修产品 bug 时遇到阻塞（如 sed 行为不一致）：
- ❌ 不允许"绕开"或"假装没发现"
- ✅ 必须停止 → 找到真正的 fix

### 7.2 不主动 commit / push

```
- AI 不主动 git commit
- AI 不主动 git push
- 我（产品作者）review 后再操作
```

### 7.3 templates/ 是产品发版的源

```
任何对 templates/ 的修改，都意味着下一版本会影响所有用户。
修改前必须：
- 评估对现有用户的影响
- 写入 CHANGELOG.md
- 标注是 PATCH / MINOR / MAJOR
```

---

## 8. 项目演进路径

```
v1.0.0-alpha (当前)
  ├─ ✅ 仓库骨架
  ├─ ✅ 产品规格4份
  ├─ ✅ 模板（10产物模板 + 4 schemas）
  ├─ ✅ skill+subagent（3 skill + 4 agent）
  ├─ ✅ 安装/验证/卸载脚本
  ├─ ✅ Dogfooding（本次！）
  └─ 🟡 待补：upgrade.sh / manifest.json / 文档完善

v1.0.x (PATCH)
  └─ 修当前发现的 bug（sed转义已修，剩 rmdir/banner 等）

v1.1 (MINOR)
  └─ Team Medium档 + upgrade.sh + manifest.json
  
v1.2 (MINOR)
  └─ Team Large档 + 多项目支持
  
v1.3 (MINOR)
  └─ Solo Edition
```

---

## 9. 文档索引

### 产品自身文档
- `README.md` - 产品门面
- `CHANGELOG.md` - 变更日志
- `docs/00-product-spec/` - 产品规格4份
- `backlog/` - 反馈+提议+bug列表

### 模板与脚本
- `templates/CLAUDE.md` - 给用户的 CLAUDE.md 模板
- `templates/.claude/` - 给用户的 .claude/ 模板（与本仓 .claude/ 通过符号链接同步）
- `templates/templates/` - 产物模板（A/B/C 三条路径）
- `scripts/init.sh` - 安装脚本
- `scripts/validate.sh` - 验证脚本
- `scripts/uninstall.sh` - 卸载脚本

### 产品的开发记录（dogfooding 产物）
- `docs/versions/active/` - 开发中的版本
- `docs/versions/archive/` - 已归档版本

---

## 10. 用户定制区（产品作者使用）

<!-- USER CUSTOMIZATION START -->

### 10.1 我的工作笔记

- dogfooding 启动日：2026-06-12
- 第一次用 /harness:req 修自己产品的 bug：v1.0.1-fix-init-bugs

### 10.2 临时规则

（暂无）

### 10.3 备注

dogfooding 是 harness-lite 最强的自证。
"自己都不愿意用的产品，别人也不会用"。

<!-- USER CUSTOMIZATION END -->

---

*Harness-Lite 自用版 CLAUDE.md · v1.0.0-alpha · 2026-06-12*
