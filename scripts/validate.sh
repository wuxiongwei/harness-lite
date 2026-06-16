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
    ".claude/skills/harness-test-ci/SKILL.md" \
    ".claude/agents/doc-generator.md" \
    ".claude/agents/reviewer.md" \
    ".claude/agents/implementer.md" \
    ".claude/agents/validator.md" \
    ".claude/hooks/pre-commit-test.sh"; do
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

# ============================================================
# settings.json schema 校验（防 v1.0.5 类回归）
# ============================================================
echo ""
echo "📋 settings.json schema 校验："

if [ ! -f ".claude/settings.json" ]; then
    echo -e "${RED}✗${NC}  .claude/settings.json 不存在"
    errors=$((errors+1))
elif command -v jq &>/dev/null; then
    schema_ok=true

    # 不变式 1-2：permissions.allow / deny 是数组
    if ! jq -e '.permissions.allow | type == "array"' ".claude/settings.json" &>/dev/null; then
        echo -e "${RED}✗${NC}  permissions.allow 不是数组（应是字符串数组）"
        schema_ok=false
    fi
    if ! jq -e '.permissions.deny | type == "array"' ".claude/settings.json" &>/dev/null; then
        echo -e "${RED}✗${NC}  permissions.deny 不是数组（应是字符串数组）"
        schema_ok=false
    fi

    # 不变式 3：没有遗留旧字段 alwaysAllow / alwaysDeny
    if jq -e '.permissions | has("alwaysAllow") or has("alwaysDeny")' ".claude/settings.json" 2>/dev/null | grep -q true; then
        echo -e "${RED}✗${NC}  发现遗留字段 alwaysAllow/alwaysDeny（v1.0.5 起改为 allow/deny）"
        schema_ok=false
    fi

    # 不变式 4：hook matcher 是字符串
    if jq -e '.hooks.PreToolUse // [] | all(.matcher | type == "string")' ".claude/settings.json" &>/dev/null; then
        :
    else
        echo -e "${RED}✗${NC}  hooks.PreToolUse[].matcher 不是字符串（应是 \"Bash\"/\"Edit\" 等工具名）"
        schema_ok=false
    fi

    # 不变式 5：hook entry 含 hooks 数组
    if jq -e '.hooks.PreToolUse // [] | all(.hooks | type == "array")' ".claude/settings.json" &>/dev/null; then
        :
    else
        echo -e "${RED}✗${NC}  hooks.PreToolUse[].hooks 不是数组（应是 [{type, command}]）"
        schema_ok=false
    fi

    # 不变式 4-5 同样校验 PostToolUse
    if jq -e '.hooks.PostToolUse // [] | all(.matcher | type == "string")' ".claude/settings.json" &>/dev/null; then
        :
    else
        echo -e "${RED}✗${NC}  hooks.PostToolUse[].matcher 不是字符串"
        schema_ok=false
    fi
    if jq -e '.hooks.PostToolUse // [] | all(.hooks | type == "array")' ".claude/settings.json" &>/dev/null; then
        :
    else
        echo -e "${RED}✗${NC}  hooks.PostToolUse[].hooks 不是数组"
        schema_ok=false
    fi

    if $schema_ok; then
        echo -e "${GREEN}✓${NC}  settings.json schema 通过（5 条不变式）"
    else
        errors=$((errors+1))
        echo -e "    ${YELLOW}修复：${NC}重装或参考 templates/.claude/settings.json"
    fi
else
    # 降级路径：jq 不存在，只做 JSON 语法校验
    if python3 -m json.tool ".claude/settings.json" &>/dev/null; then
        echo -e "${YELLOW}⚠${NC}  jq 未安装，仅校验了 JSON 语法（schema 校验需要 jq）"
        echo -e "    ${YELLOW}建议：${NC}brew install jq （macOS）或 apt install jq （Linux）"
    else
        echo -e "${RED}✗${NC}  settings.json JSON 语法错误"
        errors=$((errors+1))
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
