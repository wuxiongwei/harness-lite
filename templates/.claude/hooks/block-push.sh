#!/bin/bash
# Harness-Lite · block-push.sh
# 阻止 AI 主动 git push，所有 push 必须由用户手动确认执行
#
# 触发：PreToolUse Bash hook + if "Bash(git push*)"
# 行为：exit 2 → Claude Code 阻塞工具调用，stderr 反馈给 AI

echo "⚠️  Harness-Lite 门禁：禁止 AI 主动 push" >&2
echo "→ 请由用户在终端手动执行 git push，确认无误后再发布" >&2
exit 2
