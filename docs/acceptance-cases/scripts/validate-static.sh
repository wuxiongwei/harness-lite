#!/bin/bash
# validate-static.sh - 验收用例静态检查脚本
# 每次 push 后自动跑，验证文件结构/格式/黑名单关键词
#
# 用法：./scripts/validate-static.sh
# 返回：0=全部通过，1=有失败项

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# SCRIPT_DIR = .../harness-lite/docs/acceptance-cases/scripts
# PROJECT_ROOT = .../harness-lite (需要三层 dirname)
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

PASS=0
FAIL=0
WARN=0

pass() {
  echo "✅ $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "❌ $1"
  FAIL=$((FAIL + 1))
}

warn() {
  echo "⚠️  $1"
  WARN=$((WARN + 1))
}

# ========== UC1.1 目录结构检查 ==========

echo ""
echo "=== UC1.1 目录结构检查 ==="

# 检查 templates 目录结构（产品分发源）
test -d "$PROJECT_ROOT/templates/.claude/skills" && pass "templates/.claude/skills 目录存在" || fail "templates/.claude/skills 目录缺失"
test -d "$PROJECT_ROOT/templates/.claude/agents" && pass "templates/.claude/agents 目录存在" || fail "templates/.claude/agents 目录缺失"
test -d "$PROJECT_ROOT/templates/.claude/rules" && pass "templates/.claude/rules 目录存在" || fail "templates/.claude/rules 目录缺失"
test -f "$PROJECT_ROOT/templates/CLAUDE.md" && pass "templates/CLAUDE.md 存在" || fail "templates/CLAUDE.md 缺失"
test -f "$PROJECT_ROOT/templates/.claude/settings.json" && pass "templates/.claude/settings.json 存在" || fail "templates/.claude/settings.json 缺失"

# 检查 skill 数量
SKILL_COUNT=$(ls "$PROJECT_ROOT/templates/.claude/skills" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -ge 3 ]; then
  pass "skill 数量: $SKILL_COUNT (≥3)"
else
  fail "skill 数量不足: $SKILL_COUNT (应有 ≥3)"
fi

# 检查 agent 数量
AGENT_COUNT=$(ls "$PROJECT_ROOT/templates/.claude/agents" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGENT_COUNT" -ge 4 ]; then
  pass "agent 数量: $AGENT_COUNT (≥4)"
else
  fail "agent 数量不足: $AGENT_COUNT (应有 ≥4)"
fi

# ========== Skill 格式检查 ==========

echo ""
echo "=== Skill 格式检查 ==="

for skill_file in "$PROJECT_ROOT/templates/.claude/skills/*/SKILL.md"; do
  if [ -f "$skill_file" ]; then
    skill_name=$(basename "$(dirname "$skill_file")")

    # 检查 frontmatter
    grep -q "^name:" "$skill_file" && pass "$skill_name: 有 name 字段" || fail "$skill_name: 缺 name 字段"
    grep -q "^description:" "$skill_file" && pass "$skill_name: 有 description 字段" || fail "$skill_name: 缺 description 字段"

    # 检查 Phase 结构（应有 Phase 1-6 或类似）
    phase_count=$(grep -c "^## Phase" "$skill_file" 2>/dev/null || echo "0")
    if [ "$phase_count" -ge 2 ]; then
      pass "$skill_name: Phase 结构完整 ($phase_count 个)"
    else
      warn "$skill_name: Phase 结构可能不完整 ($phase_count 个)"
    fi
  fi
done

# ========== 黑名单关键词检查 ==========

echo ""
echo "=== 黑名单关键词检查 ==="

# 女娲残留检查
NUWA_COUNT=$(grep -r "女娲 · Skill造人术" "$PROJECT_ROOT/templates/.claude" 2>/dev/null | wc -l | tr -d ' ')
if [ "$NUWA_COUNT" -eq 0 ]; then
  pass "无女娲 skill 生成标注残留"
else
  fail "发现女娲 skill 生成标注残留 ($NUWA_COUNT 处)"
fi

# ccflow 固定模板残留检查（harness-research）
RESEARCH_FILE="$PROJECT_ROOT/templates/.claude/skills/harness-research/SKILL.md"
if [ -f "$RESEARCH_FILE" ]; then
  # 检查是否还有旧的 person/company/tech 模板定义（而非"参考维度"）
  if grep -q "### \`person\` 模板（6 维" "$RESEARCH_FILE" 2>/dev/null; then
    fail "harness-research: 发现旧 person 模板定义"
  else
    pass "harness-research: 无旧 person 模板定义"
  fi

  if grep -q "### \`company\` 模板（5 维" "$RESEARCH_FILE" 2>/dev/null; then
    fail "harness-research: 发现旧 company 模板定义"
  else
    pass "harness-research: 无旧 company 模板定义"
  fi

  if grep -q "### \`tech\` 模板（4 维" "$RESEARCH_FILE" 2>/dev/null; then
    fail "harness-research: 发现旧 tech 模板定义"
  else
    pass "harness-research: 无旧 tech 模板定义"
  fi
fi

# ========== UC5 安全配置检查 ==========

echo ""
echo "=== UC5 安全配置检查 ==="

SETTINGS_FILE="$PROJECT_ROOT/templates/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  # 检查 deny 列表
  grep -q '".env"' "$SETTINGS_FILE" && pass "settings.json: .env 在 deny 列表" || warn "settings.json: .env 未在 deny 列表"
  grep -q 'credentials' "$SETTINGS_FILE" && pass "settings.json: credentials 在 deny 列表" || warn "settings.json: credentials 未在 deny 列表"
  grep -q 'secrets' "$SETTINGS_FILE" && pass "settings.json: secrets 在 deny 列表" || warn "settings.json: secrets 未在 deny 列表"
fi

PRINCIPLES_FILE="$PROJECT_ROOT/templates/.claude/rules/principles.md"
if [ -f "$PRINCIPLES_FILE" ]; then
  grep -q "不主动 commit" "$PRINCIPLES_FILE" && pass "principles: §8 铁律存在" || fail "principles: §8 铁律缺失"
  grep -q "阻塞即停止" "$PRINCIPLES_FILE" && pass "principles: §7 铁律存在" || fail "principles: §7 铁律缺失"
  grep -q "敏感文件" "$PRINCIPLES_FILE" && pass "principles: 敏感文件保护存在" || warn "principles: 敏感文件保护未明确"
fi

# ========== 版本一致性检查 ==========

echo ""
echo "=== 版本一致性检查 ==="

VERSION_FILE="$PROJECT_ROOT/VERSION"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

if [ -f "$VERSION_FILE" ]; then
  CURRENT_VERSION=$(cat "$VERSION_FILE")
  pass "VERSION: $CURRENT_VERSION"

  # 检查 CHANGELOG 是否有对应版本
  if grep -q "## \[$CURRENT_VERSION\]" "$CHANGELOG_FILE" 2>/dev/null; then
    pass "CHANGELOG: 有 $CURRENT_VERSION 条目"
  else
    warn "CHANGELOG: 缺 $CURRENT_VERSION 条目"
  fi
fi

# ========== 结果汇总 ==========

echo ""
echo "=== 结果汇总 ==="
echo "✅ 通过: $PASS"
echo "❌ 失败: $FAIL"
echo "⚠️  警告: $WARN"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "🔴 验证失败，请修复后再发布"
  exit 1
else
  echo "🟢 静态验证通过"
  if [ "$WARN" -gt 0 ]; then
    echo "   有 $WARN 个警告，建议检查"
  fi
  exit 0
fi