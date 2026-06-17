#!/bin/bash
# Harness-Lite 升级脚本
# 用法：cd your-project && /path/to/harness-lite/scripts/upgrade.sh
#
# 设计原则：
#   1. 简单粗暴覆盖 H-L 管理范围（rules/skills/agents/hooks/templates + settings.json）
#   2. 绝不动用户数据（CLAUDE.md 业务部分 / team-knowledge / docs/versions / backlog）
#   3. 必先备份再覆盖（备份失败立即退出）
#   4. 升级后自动跑 validate.sh 兜底
#   5. 不做：manifest 化、降级、跨主版本、合并用户改动（v1.1+）

set -e

# ============================================================
# 颜色与日志
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error()   { echo -e "${RED}✗${NC}  $1" >&2; }
log_step()    { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# ============================================================
# 配置
# ============================================================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HARNESS_LITE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
TARGET_DIR="$(pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".harness-lite-upgrade-backup/$TIMESTAMP"

NEW_VERSION=$(cat "$HARNESS_LITE_ROOT/VERSION" 2>/dev/null || echo "unknown")

# ============================================================
# Banner
# ============================================================
echo ""
log_info "Harness-Lite 升级向导"
log_info "Harness-Lite location: $HARNESS_LITE_ROOT"
log_info "目标项目:              $TARGET_DIR"
log_info "可升级到:              v$NEW_VERSION"
echo ""

# ============================================================
# Step 1：前置检查
# ============================================================
log_step "Step 1/6: 前置检查"

if [ ! -d ".claude" ]; then
    log_error "未检测到 .claude/ 目录"
    log_info "  → 请先运行 init.sh 安装 Harness-Lite"
    exit 1
fi

if [ ! -f "CLAUDE.md" ]; then
    log_error "未检测到 CLAUDE.md"
    log_info "  → 请先运行 init.sh 安装 Harness-Lite"
    exit 1
fi

if ! grep -q "Harness-Lite" "CLAUDE.md" 2>/dev/null; then
    log_error "CLAUDE.md 不含 Harness-Lite 标识"
    log_info "  → 这看起来不是 Harness-Lite 管理的项目"
    exit 1
fi

log_success "环境检查通过"

# 提取旧版本号（从 CLAUDE.md 头部 "v1.0.4 生成" 模式）
OLD_VERSION=$(grep -oE "v[0-9]+\.[0-9]+\.[0-9]+( 生成|-alpha)?" CLAUDE.md 2>/dev/null \
              | head -1 | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
[ -z "$OLD_VERSION" ] && OLD_VERSION="unknown"

log_info "当前版本: v$OLD_VERSION"
log_info "目标版本: v$NEW_VERSION"

# ============================================================
# Step 2：版本对比
# ============================================================
log_step "Step 2/6: 版本对比"

if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
    log_success "已是最新版（v${NEW_VERSION}），无需升级"
    exit 0
fi

if [ "$OLD_VERSION" = "unknown" ]; then
    log_warn "无法识别旧版本号，按 'unknown → v$NEW_VERSION' 处理"
fi

log_info "将从 v$OLD_VERSION 升级到 v$NEW_VERSION"
echo ""
read -p "继续？(y/N): " confirm
if [ "$confirm" != "y" ]; then
    log_info "已取消"
    exit 0
fi

# ============================================================
# Step 3：备份
# ============================================================
log_step "Step 3/6: 备份"

mkdir -p "$BACKUP_DIR"
cp -r ".claude" "$BACKUP_DIR/" || {
    log_error "备份 .claude/ 失败"
    log_info "  → 检查磁盘空间 / 写权限"
    exit 1
}
cp "CLAUDE.md" "$BACKUP_DIR/" || {
    log_error "备份 CLAUDE.md 失败"
    exit 1
}
log_success "已备份到 $BACKUP_DIR"

# ============================================================
# Step 4：覆盖 H-L 管理范围
# ============================================================
log_step "Step 4/6: 覆盖 Harness-Lite 文件"

# rules：覆盖（H-L 标准规则），但 tech-stack-rules.md 是 init 时按用户技术栈渲染过的实例，不动
mkdir -p ".claude/rules"
# principles.md / domain-rules.md / 其他新增规则 → 覆盖
for rule_file in "$HARNESS_LITE_ROOT/templates/.claude/rules"/*.md; do
    fname=$(basename "$rule_file")
    if [ "$fname" = "tech-stack-rules.md" ]; then
        # 已渲染过的实例文件——保留用户当前内容
        if [ ! -f ".claude/rules/$fname" ]; then
            cp "$rule_file" ".claude/rules/$fname"
            log_warn "  tech-stack-rules.md 不存在，复制了模板版（含 {{...}} 占位符，需手动渲染）"
        fi
    else
        cp -f "$rule_file" ".claude/rules/$fname"
    fi
done

# 覆盖完 rules 后，渲染新文件中的版本占位符（v1.0.11 修：之前漏了导致 domain-rules.md 残留 {{...}}）
# v1.0.18 修：去掉 local 关键字，否则 macOS bash 3.2 下报错 + set -e 导致后续 upgrade 流程全部中断
upgrade_date=$(date +"%Y-%m-%d")
for rendered in ".claude/rules/principles.md" ".claude/rules/domain-rules.md"; do
    if [ -f "$rendered" ]; then
        sed -i.bak \
            -e "s#{{HARNESS_LITE_VERSION}}#$NEW_VERSION#g" \
            -e "s#{{INSTALL_DATE}}#$upgrade_date#g" \
            "$rendered"
        rm -f "$rendered.bak"
    fi
done
log_success "rules/ 已更新（tech-stack-rules.md 保留用户渲染版）"

# skills：覆盖（注意：用户加的非 harness-* skill 保留）
mkdir -p ".claude/skills"
cp -rf "$HARNESS_LITE_ROOT/templates/.claude/skills/." ".claude/skills/"
log_success "skills/ 已更新（用户自定义 skill 保留）"

# agents：覆盖
mkdir -p ".claude/agents"
cp -rf "$HARNESS_LITE_ROOT/templates/.claude/agents/." ".claude/agents/"
log_success "agents/ 已更新"

# hooks：覆盖
mkdir -p ".claude/hooks"
cp -rf "$HARNESS_LITE_ROOT/templates/.claude/hooks/." ".claude/hooks/"
chmod +x .claude/hooks/*.sh 2>/dev/null || true
log_success "hooks/ 已更新"

# templates（产物模板）：覆盖
mkdir -p ".claude/templates"
cp -rf "$HARNESS_LITE_ROOT/templates/templates/." ".claude/templates/"
log_success "产物模板已更新"

# settings.json：覆盖（schema 漂移最高频区，必须强制同步）
cp -f "$HARNESS_LITE_ROOT/templates/.claude/settings.json" ".claude/settings.json"
# 替换 _version 占位符
sed -i.bak "s#{{HARNESS_LITE_VERSION}}#$NEW_VERSION#g" .claude/settings.json
rm -f .claude/settings.json.bak
log_success "settings.json 已更新到 v$NEW_VERSION"

# ============================================================
# Step 5：CLAUDE.md 头部版本号
# ============================================================
log_step "Step 5/6: CLAUDE.md 头部版本号更新"

# 只改 "v1.0.4 生成" 模式中的版本号，其他业务内容保留
if [ "$OLD_VERSION" != "unknown" ]; then
    sed -i.bak -E "s#v${OLD_VERSION//./\\.}( 生成)#v${NEW_VERSION}\1#" CLAUDE.md
    rm -f CLAUDE.md.bak
    log_success "CLAUDE.md 头部 v$OLD_VERSION → v$NEW_VERSION"
else
    log_warn "旧版本号未知，CLAUDE.md 头部未自动更新"
    log_info "  → 请手动检查 CLAUDE.md 顶部的 'Harness-Lite v...' 是否需更新"
fi

# ============================================================
# Step 6：兜底校验
# ============================================================
log_step "Step 6/6: 升级后校验"

if [ -f "$HARNESS_LITE_ROOT/scripts/validate.sh" ]; then
    if bash "$HARNESS_LITE_ROOT/scripts/validate.sh" > /tmp/hl-upgrade-validate.log 2>&1; then
        log_success "validate.sh 全绿"
    else
        log_warn "validate.sh 报错，详见 /tmp/hl-upgrade-validate.log"
        log_info "  → 升级未中断，但建议人工核对"
    fi
fi

# ============================================================
# 完成
# ============================================================
log_step "升级完成"

echo ""
echo "  🎉 已升级 v$OLD_VERSION → v$NEW_VERSION"
echo ""
echo "  📋 后续："
log_info "     1. 启动 claude 自检（如有 Settings Error 立即报告）"
log_info "     2. 浏览 CHANGELOG.md 看新版本变更"
log_info "        $HARNESS_LITE_ROOT/CHANGELOG.md"
echo ""
echo "  💾 备份位置：$BACKUP_DIR"
log_info "     如需回退：rm -rf .claude && cp -r $BACKUP_DIR/.claude . && cp $BACKUP_DIR/CLAUDE.md ."
echo ""
log_warn "⚠️  注意：如果你曾自定义过 hook / skill / settings.json，可能被本次升级覆盖"
log_info "     → diff 工具对比：$BACKUP_DIR/.claude  vs  当前 .claude/"
echo ""
