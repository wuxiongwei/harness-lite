# Bugs Backlog

> 收集已发现的产品bug，按优先级分类。

格式：
```
## [优先级] 标题
- 发现日期：YYYY-MM-DD
- 来源：（自己/朋友/团队/...）
- 现象：
- 影响范围：
- 处理状态：（待修/修复中/已修复@版本号）
- 关联：相关issue/讨论
```

---

## P0 (阻塞，必须立即修)

（暂无）

## P1 (重要，下个版本修)

### Stock_make_money 现象："运行运行就停了，经常出现"
- 发现日期：2026-06-16
- 来源：用户在 stock_make_money 实战 H-L v1.0.4-v1.0.12 期间观察
- 现象：
  - claude REPL 跑着跑着停止响应或退出
  - 频次：经常出现
  - 用户原话："运行运行就停了，经常出现，不知道是什么原因"
- 影响范围：未确诊。可能涉及：
  - Claude Code 本身的会话超时 / 网络断 / token 耗尽 → 不属于 H-L 责任
  - hook 脚本卡住（pre-commit-test.sh / distill-prompt.sh）→ 属于 H-L
  - settings.json 中某 hook if 没正确匹配（v1.0.12 已修但 stock 之前可能存在）→ 属于 H-L
  - skill 调用某 subagent 卡死 → 属于 H-L
- 处理状态：🟡 待诊断（用户提供更多线索后定位）
- 关联：
  - v1.0.12 修了 hook if 字段格式——之前可能因 if 不匹配导致 hook 不执行（或执行错误）
  - 需要从用户处收集：(1) 通常什么操作后停？(2) 停时屏幕最后一行显示什么？(3) `~/.claude/projects/<proj-id>/` 下最新 transcript 末尾是什么？
- 待用户提供：复现路径

### `pre-commit-test.sh` 在 unknown 技术栈时静默通过（用户感知不到 noop）
- 发现日期：2026-06-16
- 来源：v1.0.12 审计 hook 时发现
- 现象：项目无 `package.json` / `pyproject.toml` 等时，pre-commit hook 直接 exit 0 + "全量测试通过"
- 影响：用户以为有保护，实际是空跑。误导大于无害
- 处理状态：🟡 待修（v1.1）
- 修法建议：
  - 改为输出 `⚠ 未识别测试框架，pre-commit hook 实际 noop（建议在 .claude/hooks/pre-commit-test.sh 配置）`
  - 不阻塞 commit（避免新项目无法 commit）

## P2 (普通，有空再修)

### bash 多字节边界 bug 持续复现（v1.0.4 / 1.0.5 / 1.0.9）
- 发现日期：v1.0.4-v1.0.9 期间累积 3 次
- 现象：macOS bash 3.2 下 `echo "中文 $VAR..."` 中文紧跟 `$VAR` 出现字节截断（"v�"）
- 影响：脚本输出可读性差，用户疑惑
- 处理状态：🟡 已加 backlog/proposals.md "bash 多字节边界守则"
- 修法：所有 shell 脚本中 `$VAR` 前后是中文时强制用 `${VAR}` 大括号包裹
