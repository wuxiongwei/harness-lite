#!/bin/bash
# Harness-Lite 卸载脚本
# 用法：cd your-project && /path/to/harness-lite/scripts/uninstall.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1" >&2; }

cat << 'EOF'

╔════════════════════════════════════════════════╗
║       🗑️  Harness-Lite 卸载向导                 ║
╚════════════════════════════════════════════════╝

EOF

log_warn "卸载将移除以下内容："
echo "  - .claude/rules/principles.md (Harness-Lite 提供的)"
echo "  - .claude/rules/tech-stack-rules.md"
echo "  - .claude/rules/domain-rules.md"
echo "  - .claude/skills/harness-* (5 个 skill)"
echo "  - .claude/agents/*.md (4 个 subagent)"
echo "  - .claude/hooks/*.sh (3 个 Harness-Lite hook 脚本)"
echo "  - .claude/templates/path-* (产物模板)"
echo "  - .claude/settings.json (Harness-Lite 版)"
echo ""

log_warn "以下内容【不会】被移除（你的数据）："
echo "  - team-knowledge/ (你的知识库)"
echo "  - docs/versions/ (你的需求版本)"
echo "  - CLAUDE.md (会备份再处理)"
echo "  - backlog/ (你的反馈记录)"
echo ""

read -p "确认卸载？输入 'YES' 继续: " confirm
if [ "$confirm" != "YES" ]; then
    log_info "已取消"
    exit 0
fi

# 备份
BACKUP_DIR=".harness-lite-uninstall-backup/$(date +%Y%m%d_%H%M%S)"
log_info "创建备份目录: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# 备份关键文件
[ -f "CLAUDE.md" ] && cp "CLAUDE.md" "$BACKUP_DIR/" && log_success "已备份 CLAUDE.md"
[ -d ".claude" ] && cp -r ".claude" "$BACKUP_DIR/" && log_success "已备份 .claude/"

# 移除 Harness-Lite 相关文件
log_info "移除 Harness-Lite 文件..."

[ -f ".claude/rules/principles.md" ] && rm ".claude/rules/principles.md" && log_success "已移除 principles.md"
[ -f ".claude/rules/tech-stack-rules.md" ] && rm ".claude/rules/tech-stack-rules.md" && log_success "已移除 tech-stack-rules.md"
[ -f ".claude/rules/domain-rules.md" ] && rm ".claude/rules/domain-rules.md" && log_success "已移除 domain-rules.md"

[ -d ".claude/skills/harness-req" ] && rm -rf ".claude/skills/harness-req"
[ -d ".claude/skills/harness-design" ] && rm -rf ".claude/skills/harness-design"
[ -d ".claude/skills/harness-review" ] && rm -rf ".claude/skills/harness-review"
[ -d ".claude/skills/harness-impact" ] && rm -rf ".claude/skills/harness-impact"
[ -d ".claude/skills/harness-test-ci" ] && rm -rf ".claude/skills/harness-test-ci"
log_success "已移除 harness-* skills"

[ -f ".claude/agents/doc-generator.md" ] && rm ".claude/agents/doc-generator.md"
[ -f ".claude/agents/reviewer.md" ] && rm ".claude/agents/reviewer.md"
[ -f ".claude/agents/implementer.md" ] && rm ".claude/agents/implementer.md"
[ -f ".claude/agents/validator.md" ] && rm ".claude/agents/validator.md"
log_success "已移除 4 个 subagent"

# Harness-Lite 提供的 hooks 脚本（v1.0.5+ 引入）
[ -f ".claude/hooks/pre-commit-test.sh" ] && rm ".claude/hooks/pre-commit-test.sh"
[ -f ".claude/hooks/block-push.sh" ] && rm ".claude/hooks/block-push.sh"
[ -f ".claude/hooks/distill-prompt.sh" ] && rm ".claude/hooks/distill-prompt.sh"
log_success "已移除 hook 脚本"

[ -d ".claude/templates/path-a" ] && rm -rf ".claude/templates/path-a"
[ -d ".claude/templates/path-b" ] && rm -rf ".claude/templates/path-b"
[ -d ".claude/templates/path-c" ] && rm -rf ".claude/templates/path-c"
log_success "已移除产物模板"

# settings.json: 仅当含 Harness-Lite 标识时移除
if [ -f ".claude/settings.json" ] && grep -q "Harness-Lite" ".claude/settings.json"; then
    rm ".claude/settings.json"
    log_success "已移除 .claude/settings.json"
fi

# 提醒用户手动处理 CLAUDE.md
echo ""
log_warn "⚠️  CLAUDE.md 不会自动修改，需要你手动处理："
log_info "  1. 移除 @import .claude/rules/* 引用"
log_info "  2. 移除 Harness-Lite 相关内容"
log_info "  3. 备份在 $BACKUP_DIR/CLAUDE.md"

# 清理空目录
rmdir ".claude/skills" 2>/dev/null || true
rmdir ".claude/agents" 2>/dev/null || true
rmdir ".claude/rules" 2>/dev/null || true
rmdir ".claude/hooks" 2>/dev/null || true
rmdir ".claude/templates" 2>/dev/null || true
# Bug #2 修复：清理空的 .claude/ 父目录（如果用户没有其他文件在里面）
rmdir ".claude" 2>/dev/null && log_success "已清理空的 .claude/ 目录" || log_info ".claude/ 仍含其他文件，保留"

echo ""
log_success "卸载完成"
log_info "备份位置：$BACKUP_DIR"
log_info "如需恢复：cp -r $BACKUP_DIR/.claude . && cp $BACKUP_DIR/CLAUDE.md ."
echo ""
