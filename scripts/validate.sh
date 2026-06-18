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
    "team-knowledge/wiki/pitfalls" \
    "team-knowledge/wiki/decisions" \
    "team-knowledge/wiki/interfaces" \
    "team-knowledge/wiki/architecture" \
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

# 全量扫 CLAUDE.md / rules 中残留的占位符（防 v1.0.11 类回归）
set +e
unrendered=$(grep -lE "\{\{[A-Z_]+\}\}" \
    CLAUDE.md \
    .claude/rules/*.md \
    2>/dev/null)
set -e
if [ -n "$unrendered" ]; then
    echo -e "${RED}✗${NC}  以下文件含未渲染的 {{...}} 占位符："
    echo "$unrendered" | while read f; do
        ph=$(grep -oE "\{\{[A-Z_]+\}\}" "$f" 2>/dev/null | sort -u | tr '\n' ' ')
        echo "      $f → $ph"
    done
    errors=$((errors+1))
else
    echo -e "${GREEN}✓${NC}  CLAUDE.md / rules 占位符已全部渲染"
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

    # 不变式 6：hook 内 if 字段不能用 "Bash(xxx*)"（紧贴 *），官方语法是 "Bash(xxx *)"（带空格）
    # 详见 https://code.claude.com/docs/en/hooks—— v1.0.12 修复同根第 5 次 schema 漂移
    # regex 思路：找括号内最后字符是 [a-zA-Z]\* 紧贴的，即缺空格 → 报错
    bad_if=$(jq -r '
        [.hooks.PreToolUse, .hooks.PostToolUse] | flatten | map(.hooks[]?.if // empty)
        | map(select(test("\\([^)]*[a-zA-Z]\\*\\)")))
        | .[]
    ' ".claude/settings.json" 2>/dev/null)
    if [ -n "$bad_if" ]; then
        echo -e "${RED}✗${NC}  hook 'if' 字段格式错误（命令与 * 之间缺空格）："
        echo "$bad_if" | sed 's/^/      /'
        echo -e "    ${YELLOW}修法：${NC}'Bash(git commit*)' → 'Bash(git commit *)'（命令与 * 之间必须有空格）"
        schema_ok=false
    fi

    if $schema_ok; then
        echo -e "${GREEN}✓${NC}  settings.json schema 通过（6 条不变式）"
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

# ============================================================
# skill / agent frontmatter schema 校验（防 v1.0.7 类回归）
# ============================================================
echo ""
echo "📋 skill / agent frontmatter 校验："

skill_agent_ok=true

# 临时关闭 set -e —— 这一段大量用 grep -l/-L，未匹配时返回非零是正常的
set +e

# 检查 skill 不含废弃字段 trigger / version
if ls .claude/skills/*/SKILL.md &>/dev/null; then
    bad_trigger=$(grep -lE "^trigger:" .claude/skills/*/SKILL.md 2>/dev/null)
    bad_version=$(grep -lE "^version:" .claude/skills/*/SKILL.md 2>/dev/null)
    if [ -n "$bad_trigger" ]; then
        echo -e "${RED}✗${NC}  skill 包含废弃字段 'trigger:'（v1.0.7 起改用 description 触发）："
        echo "$bad_trigger" | sed 's/^/      /'
        skill_agent_ok=false
    fi
    if [ -n "$bad_version" ]; then
        echo -e "${RED}✗${NC}  skill 包含废弃字段 'version:'（v1.0.7 起删除）："
        echo "$bad_version" | sed 's/^/      /'
        skill_agent_ok=false
    fi
fi

# 检查 agent 不含废弃字段 visible / invisible
if ls .claude/agents/*.md &>/dev/null; then
    bad_visible=$(grep -lE "^visible:|^invisible:" .claude/agents/*.md 2>/dev/null)
    if [ -n "$bad_visible" ]; then
        echo -e "${RED}✗${NC}  agent 包含废弃字段 'visible:'/'invisible:'（v1.0.7 起改用 tools 字段 + system prompt 描述可见性）："
        echo "$bad_visible" | sed 's/^/      /'
        skill_agent_ok=false
    fi
fi

# 检查 skill 是否有 description（触发的关键）
if ls .claude/skills/*/SKILL.md &>/dev/null; then
    no_desc=$(grep -L "^description:" .claude/skills/*/SKILL.md 2>/dev/null)
    if [ -n "$no_desc" ]; then
        echo -e "${RED}✗${NC}  skill 缺少 'description:' 字段（Claude 通过 description 决定何时触发）："
        echo "$no_desc" | sed 's/^/      /'
        skill_agent_ok=false
    fi
fi

# 检查文档是否还残留旧调用名 /harness:
if ls .claude/skills/*/SKILL.md &>/dev/null || [ -f "CLAUDE.md" ]; then
    bad_invoke=$(grep -lE "/harness:" .claude/skills/*/SKILL.md .claude/agents/*.md CLAUDE.md 2>/dev/null)
    if [ -n "$bad_invoke" ]; then
        echo -e "${RED}✗${NC}  发现旧调用名 '/harness:'（v1.0.7 起改为 '/harness-'，目录名即调用名）："
        echo "$bad_invoke" | sed 's/^/      /'
        skill_agent_ok=false
    fi
fi

# 恢复 set -e
set -e

if $skill_agent_ok; then
    echo -e "${GREEN}✓${NC}  skill / agent frontmatter 通过"
else
    errors=$((errors+1))
    echo -e "    ${YELLOW}修复：${NC}重装或参考 templates/.claude/{skills,agents}/"
fi



# ============================================================
# 用户故事真闭环检查（v1.0.27 · 防"完成"但用户用不了的 bug）
# ============================================================
echo ""
echo "📋 用户故事真闭环检查（v1.0.27+ · principles §6.1）："

set +e
user_story_ok=true

# 扫描所有 active 版本的 01-需求.md + 05-完成.md
if [ -d "docs/versions/active" ]; then
    for version_dir in docs/versions/active/*/; do
        version_name=$(basename "$version_dir")
        req_file="$version_dir/01-需求.md"
        done_file="$version_dir/05-完成.md"

        # 01-需求 含用户故事 / AC → 05-完成 必须含"用户路径自检"段
        if [ -f "$req_file" ]; then
            if grep -qE "用户故事|验收标准|AC" "$req_file" 2>/dev/null; then
                # 该版本有用户故事
                if [ -f "$done_file" ]; then
                    if ! grep -q "用户路径自检\|用户从哪开始" "$done_file" 2>/dev/null; then
                        echo -e "${RED}✗${NC}  $version_name: 01-需求 含用户故事，但 05-完成 缺'用户路径自检'段（§6.1 违规）"
                        user_story_ok=false
                    fi
                else
                    # 05-完成 还没写（可能在进行中）→ 警告
                    echo -e "${YELLOW}⚠${NC}  $version_name: 01-需求 含用户故事，但 05-完成.md 不存在（可能进行中）"
                fi
            fi
        fi
    done
fi
set -e

if $user_story_ok; then
    if [ -d "docs/versions/active" ] && [ "$(ls -A docs/versions/active 2>/dev/null)" ]; then
        echo -e "${GREEN}✓${NC}  用户故事真闭环检查通过"
    else
        echo -e "${YELLOW}⚠${NC}  无 active 版本（未启用 path-a）"
    fi
else
    errors=$((errors+1))
    echo -e "    ${YELLOW}修复：${NC}05-完成.md 必须含'用户路径自检'段（见 templates/templates/path-a/05-完成.md）"
    echo -e "    ${YELLOW}原因：${NC}v1.0.27 用户反馈——没有此段的版本常误报'完成'但用户实际用不了"
fi


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✅ 所有检查通过！${NC}"
    echo ""
    echo "Harness-Lite 就绪！使用方法："
    echo ""
    echo "  1. claude（启动 Claude Code）"
    echo "  2. /clear"
    echo "  3. 介绍一下我们项目（验证 AI 是否加载规则）"
    echo ""
else
    echo -e "${RED}✗ 发现 $errors 个问题${NC}"
    echo ""
    echo "请根据上方提示修复，或参考文档："
    echo "  - 快速上手：docs/01-getting-started/01-quickstart.md"
    echo "  - 完整文档：README.md"
    echo ""
    exit 1
fi
