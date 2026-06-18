# 分支策略（团队约定）

> 本文件**入仓库**，团队共享。修改前与团队同步。
> AI 在 commit / push 时按本文件检查分支名（**软提醒不阻塞**）。

---

## 命名规范

```
feat/<short-name>          # 新功能
fix/<short-name>           # bug 修复
refactor/<short-name>      # 重构
docs/<short-name>          # 文档
chore/<short-name>         # 杂项（依赖更新 / 配置等）
hotfix/<short-name>        # 紧急修复（直推 main）
```

**short-name 规范**：
- 全小写
- 单词间用 `-` 连接
- ≤ 30 字符
- 含动词或场景关键词（如 `add-search` / `fix-login-500`）

## 主分支保护

- `main`：禁止直推（仅 hotfix 例外）
- `develop`：仅团队 lead 可推
- 其他分支自由

## 合并规则

- 必须经过至少 1 人 review
- 必须通过 pre-commit hook（含全量测试）
- **推荐 squash merge**（保持历史干净）
- PR 标题与分支名一致

## 示例

```
✅ feat/user-search-by-email
✅ fix/login-500-on-empty-password
✅ docs/quickstart-update
❌ alice-new-feature           # 缺类型前缀
❌ feature/search              # 用 feat 不用 feature
❌ FIX/LOGIN                   # 前缀必须小写
```

## 当前分支建议（团队按需自定义）

<!-- 团队可在此区域添加项目特定建议 -->

例：
- 重构 schema 类需求统一用 `refactor/schema-xxx`
- 紧急 hotfix 需通知 lead

---

> 不存在本文件时，AI 跳过分支检查（向下兼容 v1.0.22）。
> 修改本文件后，团队同步并 review。

*Harness-Lite v1.0.23+ 多人协同协议·分支策略*
