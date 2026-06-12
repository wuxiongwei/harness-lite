#!/bin/bash
# Harness-Lite 安装验证脚本
# 用法：cd your-project && /path/to/harness-lite/scripts/validate.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_check() {
    if [ -e "$1" ]; then
        echo -e "${GREEN}✓${NC}  $1"
        return 0
    else
        echo -e "${RED}✗${NC}  $1 ${RED}缺失${NC}"
        return 1
    fi
}

echo ""
echo "🔍 Harness-Lite 安装自检"
echo ""

errors=0

echo "📁 文件检查："
for f in \
    "CLAUDE.md" \
    ".claude/settings.json" \
    ".claude/rules/principles.md" \
    ".claude/rules/tech-stack-rules.md" \
    ".claude/rules/domain-rules.md" \
    ".claude/skills/harness-req/SKILL.md" \
    ".claude/skills/harness-design/SKILL.md" \
    ".claude/skills/harness-review/SKILL.md" \
    ".claude/agents/doc-generator.md" \
    ".claude/agents/reviewer.md" \
    ".claude/agents/implementer.md" \
    ".claude/agents/validator.md"; do
    log_check "$f" || errors=$((errors+1))
done

echo ""
echo "📂 目录检查："
for d in \
    ".claude/templates/path-a" \
    ".claude/templates/path-b" \
    ".claude/templates/path-c" \
    "team-knowledge/wiki" \
    "team-knowledge/raw" \
    "team-knowledge/schemas" \
    "docs/versions/active"; do
    log_check "$d" || errors=$((errors+1))
done

echo ""
echo "🔧 配置检查："
if [ -f "CLAUDE.md" ] && grep -q "Harness-Lite" "CLAUDE.md"; then
    echo -e "${GREEN}✓${NC}  CLAUDE.md 含 Harness-Lite 标识"
else
    echo -e "${YELLOW}⚠${NC}  CLAUDE.md 不含 Harness-Lite 标识（可能未合并模板）"
    if [ -f "CLAUDE.md.harness-lite-template" ]; then
        echo -e "    ${YELLOW}提示：${NC}请手动合并 CLAUDE.md.harness-lite-template 到 CLAUDE.md"
    fi
fi

if [ -f ".claude/rules/tech-stack-rules.md" ]; then
    if grep -q "{{" ".claude/rules/tech-stack-rules.md"; then
        echo -e "${YELLOW}⚠${NC}  tech-stack-rules.md 中仍有未渲染的变量 {{...}}"
        errors=$((errors+1))
    else
        echo -e "${GREEN}✓${NC}  tech-stack-rules.md 已渲染"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✅ 所有检查通过！${NC}"
    echo ""
    echo "下一步："
    echo "  1. claude（启动 Claude Code）"
    echo "  2. /clear"
    echo "  3. 介绍一下我们项目（验证 AI 是否加载规则）"
    exit 0
else
    echo -e "${RED}✗ 发现 $errors 个问题${NC}"
    echo ""
    echo "建议："
    echo "  - 重新运行 init.sh"
    echo "  - 或检查上述缺失项手动修复"
    exit 1
fi
