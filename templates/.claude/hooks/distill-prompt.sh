#!/bin/bash
# Harness-Lite · distill-prompt.sh
# 在写入 04-*.md（路径 A 测试 / 路径 B 验证 / 路径 C 回归）后提示蒸馏知识
#
# 触发：PostToolUse Write hook + if "Write(docs/versions/active/**/04-*.md)"
# 行为：exit 0 + 打印提示（PostToolUse 不能阻塞，只能反馈）

cat << 'EOF'

📚 Harness-Lite 提示：本需求即将收尾，是否有值得沉淀的知识？

  - 踩坑   → team-knowledge/wiki/pitfalls/
  - 决策   → team-knowledge/wiki/decisions/
  - 接口   → team-knowledge/wiki/interfaces/
  - 架构   → team-knowledge/wiki/architecture/

EOF
exit 0
