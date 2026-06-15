#!/bin/bash
# Harness-Lite 智能初始化脚本
# 用法：cd your-project && /path/to/harness-lite/scripts/init.sh
#
# 设计原则（借鉴 AI-TDD-Harness）：
#   1. 只复制+校验，不改用户已有文件
#   2. 不自动改 CLAUDE.md（输出片段让用户手动合并）
#   3. 已存在的同名文件备份到 .claude/backup/{timestamp}/
#   4. 安装可重复执行（幂等）

set -e  # 任何错误立即退出

# ============================================================
# 颜色与日志
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1" >&2; }
log_step() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# ============================================================
# 配置变量
# ============================================================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HARNESS_LITE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
TARGET_DIR="$(pwd)"
BACKUP_DIR=".claude/backup/$(date +%Y%m%d_%H%M%S)"

# 用户输入收集
TIER=""              # lite / standard / pro
PROJECT_NAME=""
PROJECT_TAGLINE=""
BUSINESS_DESC=""
TEAM_SIZE=""
PROJECT_STAGE=""
TECH_STACK_BACKEND=""
TECH_STACK_FRONTEND=""
DATABASE=""

# Harness-Lite 自身版本
HARNESS_LITE_VERSION=$(cat "$HARNESS_LITE_ROOT/VERSION" 2>/dev/null || echo "1.0.0-alpha")

# ============================================================
# Banner
# ============================================================
print_banner() {
    cat << 'EOF'
╔══════════════════════════════════════════════════╗
║                                                  ║
║       🎯 Harness-Lite 智能初始化向导              ║
║                                                  ║
║   AI协作工程化框架 · 让小团队也能享受工程化红利     ║
║                                                  ║
╚══════════════════════════════════════════════════╝
EOF
    echo ""
    log_info "Harness-Lite version: $HARNESS_LITE_VERSION"
    log_info "Harness-Lite location: $HARNESS_LITE_ROOT"
    log_info "Target project: $TARGET_DIR"
    echo ""
}

# ============================================================
# Step 1: 环境检查
# ============================================================
check_prerequisites() {
    log_step "Step 1/6: 环境检查"

    # 检查是否在 git 仓库
    if [ ! -d ".git" ]; then
        log_warn "当前目录不是 git 仓库"
        read -p "是否继续安装？(y/N): " confirm
        [ "$confirm" != "y" ] && log_error "已取消" && exit 1
    else
        log_success "Git 仓库检测通过"
    fi

    # 检查 Claude Code（warning）
    if ! command -v claude &> /dev/null; then
        log_warn "未检测到 Claude Code CLI，安装后可能需要手动配置"
    else
        log_success "Claude Code 已安装"
    fi

    # 检查是否已安装过
    if [ -f "CLAUDE.md" ] && grep -q "Harness-Lite" "CLAUDE.md" 2>/dev/null; then
        log_warn "检测到已安装 Harness-Lite"
        read -p "继续安装会备份现有文件，是否继续？(y/N): " confirm
        [ "$confirm" != "y" ] && log_error "已取消" && exit 1
    fi

    log_success "环境检查通过"
}

# ============================================================
# Step 2: 技术栈自动识别
# ============================================================
detect_tech_stack() {
    log_step "Step 2/6: 技术栈识别"

    # 后端识别
    if [ -f "pom.xml" ]; then
        TECH_STACK_BACKEND="Java + Spring Boot"
        log_success "检测到后端：Java + Spring Boot (pom.xml)"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        TECH_STACK_BACKEND="Java/Kotlin + Gradle"
        log_success "检测到后端：Java/Kotlin (Gradle)"
    elif [ -f "package.json" ] && grep -q '"express"\|"koa"\|"nestjs"' "package.json" 2>/dev/null; then
        TECH_STACK_BACKEND="Node.js"
        log_success "检测到后端：Node.js"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        TECH_STACK_BACKEND="Python"
        log_success "检测到后端：Python"
    elif [ -f "go.mod" ]; then
        TECH_STACK_BACKEND="Go"
        log_success "检测到后端：Go"
    fi

    # 前端识别
    if [ -f "package.json" ]; then
        if grep -q '"vue"' "package.json" 2>/dev/null; then
            TECH_STACK_FRONTEND="Vue"
            log_success "检测到前端：Vue"
        elif grep -q '"react"' "package.json" 2>/dev/null; then
            TECH_STACK_FRONTEND="React"
            log_success "检测到前端：React"
        fi
    fi

    # 数据库识别（best effort）
    if grep -rq "mysql" --include="*.yml" --include="*.yaml" --include="*.properties" . 2>/dev/null; then
        DATABASE="MySQL"
    elif grep -rq "postgres" --include="*.yml" --include="*.yaml" --include="*.properties" . 2>/dev/null; then
        DATABASE="PostgreSQL"
    elif grep -rq "mongodb" --include="*.yml" --include="*.yaml" --include="*.properties" . 2>/dev/null; then
        DATABASE="MongoDB"
    fi

    [ -z "$TECH_STACK_BACKEND" ] && TECH_STACK_BACKEND="（请手动填写）"
    [ -z "$TECH_STACK_FRONTEND" ] && TECH_STACK_FRONTEND="（请手动填写）"
    [ -z "$DATABASE" ] && DATABASE="（请手动填写）"
}

# ============================================================
# Step 2.5: 项目元信息提取（README / pyproject / package.json）
# ============================================================
# 优先级：pyproject.toml > package.json > 目录名
extract_project_name() {
    if [ -f "pyproject.toml" ]; then
        local n=$(grep -E "^name[[:space:]]*=" pyproject.toml | head -1 \
                  | sed -E 's/^name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/')
        [ -n "$n" ] && echo "$n" && return
    fi
    if [ -f "package.json" ]; then
        local n=$(grep -E '"name"[[:space:]]*:' package.json | head -1 \
                  | sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
        [ -n "$n" ] && echo "$n" && return
    fi
    basename "$TARGET_DIR"
}

# 优先级：README.md 第一段非空非标题行 > pyproject description > package.json description
extract_tagline() {
    if [ -f "README.md" ]; then
        local t=$(awk '
            /^[[:space:]]*$/ {next}
            /^#/ {next}
            {print; exit}
        ' README.md)
        [ -n "$t" ] && echo "$t" && return
    fi
    if [ -f "pyproject.toml" ]; then
        local t=$(grep -E "^description[[:space:]]*=" pyproject.toml | head -1 \
                  | sed -E 's/^description[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/')
        [ -n "$t" ] && echo "$t" && return
    fi
    if [ -f "package.json" ]; then
        local t=$(grep -E '"description"[[:space:]]*:' package.json | head -1 \
                  | sed -E 's/.*"description"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
        [ -n "$t" ] && echo "$t" && return
    fi
    echo ""
}

# 业务描述：README.md 第一个 # 标题之后到第一个 ## 之前的内容（前 300 字）
extract_business_desc() {
    if [ -f "README.md" ]; then
        local d=$(awk '
            /^# / {if (got_h1) exit; got_h1=1; next}
            /^## / {exit}
            got_h1 && NF {gsub(/^[[:space:]]+|[[:space:]]+$/,""); buf = buf $0 " "}
            END {print buf}
        ' README.md)
        # 限 300 字（中文按字节数会偏短，可接受）
        [ -n "$d" ] && echo "$(echo "$d" | head -c 300)" && return
    fi
    echo ""
}

# ============================================================
# Step 3: 用户交互 - 团队规模
# ============================================================
interactive_tier() {
    log_step "Step 3/6: 团队规模选择"

    cat << 'EOF'

  📦 选择档位：

  1) Lite     - 单兵/小团队 (1-3人)   [✅ 当前支持]
  2) Standard - 中等团队 (4-10人)     [✅ 当前支持]
  3) Pro      - 大团队 (11-30人)      [v1.1 计划支持，当前安装为 Standard 档]

EOF

    read -p "请选择 [1/2/3]（默认2）: " tier_choice
    tier_choice=${tier_choice:-2}

    case $tier_choice in
        1)
            TIER="lite"
            log_success "已选择：Lite 档（1-3人）"
            ;;
        2)
            TIER="standard"
            log_success "已选择：Standard 档（4-10人）"
            ;;
        3)
            log_warn "Pro档位 v1.1 才支持，当前安装为 Standard 档"
            TIER="standard"
            ;;
        *)
            log_error "无效选择"
            exit 1
            ;;
    esac
}

# ============================================================
# Step 4: 用户交互 - 项目信息
# ============================================================
interactive_project_info() {
    log_step "Step 4/6: 项目信息"

    # 自动提取项目元信息
    local default_project_name=$(extract_project_name)
    local default_tagline=$(extract_tagline)
    local default_business_desc=$(extract_business_desc)
    local default_team_size
    case "$TIER" in
        lite)     default_team_size="1-3人" ;;
        standard) default_team_size="4-10人" ;;
        *)        default_team_size="4-10人" ;;
    esac

    # 给用户看自动提取的预览（如果提到了东西）
    echo ""
    if [ -n "$default_tagline" ] || [ -n "$default_business_desc" ]; then
        log_info "自动从 README/pyproject/package.json 提取项目信息："
        log_info "  项目名：$default_project_name"
        [ -n "$default_tagline" ] && log_info "  定位：  $default_tagline"
        if [ -n "$default_business_desc" ]; then
            local preview=$(echo "$default_business_desc" | head -c 100)
            log_info "  描述：  ${preview}..."
        fi
        echo ""
        log_info "下面所有提示直接回车 = 采用自动提取值；输入新值会覆盖"
        echo ""
    fi

    # 注意：read -p 在 macOS bash 3.2 下，提示词末尾紧跟「变量+中文括号」会乱码
    # 解决：用 printf 提前打提示词，read 不带 -p
    printf "项目名 [%s]: " "$default_project_name"
    read PROJECT_NAME
    PROJECT_NAME=${PROJECT_NAME:-"$default_project_name"}

    if [ -n "$default_tagline" ]; then
        printf "一句话定位 [%s]: " "$default_tagline"
        read PROJECT_TAGLINE
        PROJECT_TAGLINE=${PROJECT_TAGLINE:-"$default_tagline"}
    else
        printf "一句话定位（如：电商平台后端服务）[默认 %s]: " "$PROJECT_NAME"
        read PROJECT_TAGLINE
        PROJECT_TAGLINE=${PROJECT_TAGLINE:-"$PROJECT_NAME"}
    fi

    if [ -n "$default_business_desc" ]; then
        echo ""
        log_info "业务描述自动提取："
        echo "  $default_business_desc"
        echo ""
        printf "业务描述（回车采用上面提取值，或输入新内容覆盖）: "
        read BUSINESS_DESC
        BUSINESS_DESC=${BUSINESS_DESC:-"$default_business_desc"}
    else
        printf "业务描述（详细一些）[默认 待补充]: "
        read BUSINESS_DESC
        BUSINESS_DESC=${BUSINESS_DESC:-"待补充"}
    fi

    printf "团队规模 [%s]: " "$default_team_size"
    read TEAM_SIZE
    TEAM_SIZE=${TEAM_SIZE:-"$default_team_size"}

    printf "项目阶段 (new/maintaining/refactoring) [maintaining]: "
    read PROJECT_STAGE
    PROJECT_STAGE=${PROJECT_STAGE:-"maintaining"}

    echo ""
    log_info "技术栈识别结果："
    log_info "  后端：$TECH_STACK_BACKEND"
    log_info "  前端：$TECH_STACK_FRONTEND"
    log_info "  数据库：$DATABASE"

    printf "是否需要修改技术栈？(y/N): "
    read modify_tech
    if [ "$modify_tech" = "y" ]; then
        printf "后端技术栈: "
        read input_be
        [ -n "$input_be" ] && TECH_STACK_BACKEND="$input_be"
        printf "前端技术栈: "
        read input_fe
        [ -n "$input_fe" ] && TECH_STACK_FRONTEND="$input_fe"
        printf "数据库: "
        read input_db
        [ -n "$input_db" ] && DATABASE="$input_db"
    fi
}

# ============================================================
# Step 5: 模板复制 + 变量渲染
# ============================================================
install_templates() {
    log_step "Step 5/6: 安装模板"

    # 备份已有文件（用全局变量，方便 print_next_steps 访问）
    INSTALL_HAD_BACKUP=0
    for f in "CLAUDE.md" ".claude"; do
        if [ -e "$TARGET_DIR/$f" ]; then
            INSTALL_HAD_BACKUP=1
            break
        fi
    done

    if [ "$INSTALL_HAD_BACKUP" = "1" ]; then
        log_info "检测到已有文件，备份到 $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        for f in "CLAUDE.md" ".claude"; do
            if [ -e "$TARGET_DIR/$f" ]; then
                cp -r "$TARGET_DIR/$f" "$BACKUP_DIR/"
                log_success "已备份: $f"
            fi
        done
    fi

    # 复制模板文件
    log_info "复制模板..."
    cp "$HARNESS_LITE_ROOT/templates/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md.tmp" 2>/dev/null || true
    cp "$HARNESS_LITE_ROOT/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md.harness-lite-template"

    # 注意：不直接覆盖 CLAUDE.md，而是生成 .harness-lite-template 让用户手动合并

    # 复制 .claude/ 目录
    if [ -d "$TARGET_DIR/.claude" ]; then
        # 已有 .claude —— 智能合并：只注入 Harness-Lite 特有子目录，不动用户已有文件
        log_info "已有 .claude/ 目录，智能合并 Harness-Lite 文件..."
        mkdir -p "$TARGET_DIR/.claude/rules"
        mkdir -p "$TARGET_DIR/.claude/skills"
        mkdir -p "$TARGET_DIR/.claude/agents"
        mkdir -p "$TARGET_DIR/.claude/hooks"
        # rules 直接覆盖（Harness-Lite 管理的文件）
        cp -r "$HARNESS_LITE_ROOT/templates/.claude/rules/." "$TARGET_DIR/.claude/rules/"
        # skills 追加（不覆盖用户已有 skill）
        cp -rn "$HARNESS_LITE_ROOT/templates/.claude/skills/." "$TARGET_DIR/.claude/skills/"
        # agents 追加
        cp -rn "$HARNESS_LITE_ROOT/templates/.claude/agents/." "$TARGET_DIR/.claude/agents/"
        # hooks 追加
        cp -rn "$HARNESS_LITE_ROOT/templates/.claude/hooks/." "$TARGET_DIR/.claude/hooks/"
        # settings.json: 仅在没有时才创建（不覆盖用户已有配置）
        if [ ! -f "$TARGET_DIR/.claude/settings.json" ]; then
            cp "$HARNESS_LITE_ROOT/templates/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
            log_success ".claude/settings.json 已创建"
        else
            log_warn ".claude/settings.json 已存在，跳过（避免覆盖用户配置）"
            log_info "  → 如需更新，参考 $HARNESS_LITE_ROOT/templates/.claude/settings.json"
        fi
        log_success ".claude/ 智能合并完成（已有文件保留）"
    else
        cp -r "$HARNESS_LITE_ROOT/templates/.claude" "$TARGET_DIR/.claude"
        log_success ".claude/ 目录已安装"
    fi

    # 复制产物模板
    mkdir -p "$TARGET_DIR/.claude/templates"
    cp -rn "$HARNESS_LITE_ROOT/templates/templates/"* "$TARGET_DIR/.claude/templates/" 2>/dev/null || true
    log_success "产物模板已安装到 .claude/templates/"

    # 复制 team-knowledge
    if [ ! -d "$TARGET_DIR/team-knowledge" ]; then
        cp -r "$HARNESS_LITE_ROOT/templates/team-knowledge" "$TARGET_DIR/team-knowledge"
        log_success "team-knowledge/ 已安装"
    else
        log_warn "team-knowledge/ 已存在，跳过（保护用户数据）"
    fi

    # 创建版本目录
    mkdir -p "$TARGET_DIR/docs/versions/active"
    mkdir -p "$TARGET_DIR/docs/versions/archive"
    mkdir -p "$TARGET_DIR/docs/scripts"
    mkdir -p "$TARGET_DIR/docs/report"
    log_success "docs/versions/ 目录已创建"
}

# ============================================================
# 模板变量渲染
# ============================================================
render_template_vars() {
    log_info "渲染模板变量..."

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local install_date=$(date +"%Y-%m-%d")

    # 渲染 CLAUDE.md.harness-lite-template
    # 注意：sed 分隔符用 # 避免 | 与变量值冲突；TECH_STACK 用 / 替代 | 防止冲突
    local target="$TARGET_DIR/CLAUDE.md.harness-lite-template"
    if [ -f "$target" ]; then
        local tech_stack_str="$TECH_STACK_BACKEND / $TECH_STACK_FRONTEND / $DATABASE"
        local project_type_str="$TECH_STACK_BACKEND + $TECH_STACK_FRONTEND"
        sed -i.bak \
            -e "s#{{PROJECT_NAME}}#$PROJECT_NAME#g" \
            -e "s#{{PROJECT_TAGLINE}}#$PROJECT_TAGLINE#g" \
            -e "s#{{BUSINESS_DESCRIPTION}}#$BUSINESS_DESC#g" \
            -e "s#{{PROJECT_TYPE}}#$project_type_str#g" \
            -e "s#{{TECH_STACK}}#$tech_stack_str#g" \
            -e "s#{{TEAM_SIZE}}#$TEAM_SIZE#g" \
            -e "s#{{PROJECT_STAGE}}#$PROJECT_STAGE#g" \
            -e "s#{{HARNESS_LITE_VERSION}}#$HARNESS_LITE_VERSION#g" \
            -e "s#{{INSTALL_DATE}}#$install_date#g" \
            -e "s#{{LAST_UPDATE}}#$install_date#g" \
            -e "s#{{PROJECT_VERSION}}#0.1.0#g" \
            "$target"
        rm -f "$target.bak"
    fi

    # 渲染 tech-stack-rules.md
    local rules_file="$TARGET_DIR/.claude/rules/tech-stack-rules.md"
    if [ -f "$rules_file" ]; then
        sed -i.bak \
            -e "s#{{LANGUAGE_BACKEND}}#$TECH_STACK_BACKEND#g" \
            -e "s#{{LANGUAGE_FRONTEND}}#$TECH_STACK_FRONTEND#g" \
            -e "s#{{DATABASE}}#$DATABASE#g" \
            -e "s#{{HARNESS_LITE_VERSION}}#$HARNESS_LITE_VERSION#g" \
            -e "s#{{INSTALL_DATE}}#$install_date#g" \
            -e "s#{{UI_LIBRARY}}#（请填写）#g" \
            "$rules_file"
        rm -f "$rules_file.bak"
    fi

    # 渲染 domain-rules.md
    local domain_file="$TARGET_DIR/.claude/rules/domain-rules.md"
    if [ -f "$domain_file" ]; then
        sed -i.bak \
            -e "s#{{HARNESS_LITE_VERSION}}#$HARNESS_LITE_VERSION#g" \
            -e "s#{{INSTALL_DATE}}#$install_date#g" \
            "$domain_file"
        rm -f "$domain_file.bak"
    fi

    # 渲染 settings.json
    local settings_file="$TARGET_DIR/.claude/settings.json"
    if [ -f "$settings_file" ]; then
        sed -i.bak \
            -e "s#{{HARNESS_LITE_VERSION}}#$HARNESS_LITE_VERSION#g" \
            "$settings_file"
        rm -f "$settings_file.bak"
    fi

    # 如果用户没有 CLAUDE.md，自动改名（关键改进！）
    if [ ! -f "$TARGET_DIR/CLAUDE.md" ] && [ -f "$TARGET_DIR/CLAUDE.md.harness-lite-template" ]; then
        mv "$TARGET_DIR/CLAUDE.md.harness-lite-template" "$TARGET_DIR/CLAUDE.md"
        log_success "CLAUDE.md 已自动创建"
    fi

    log_success "模板变量已渲染"
}

# ============================================================
# Step 6: 验证安装
# ============================================================
validate_installation() {
    log_step "Step 6/6: 安装验证"

    local errors=0

    # 检查关键文件
    local required_files=(
        ".claude/rules/principles.md"
        ".claude/rules/tech-stack-rules.md"
        ".claude/rules/domain-rules.md"
        ".claude/settings.json"
        ".claude/skills/harness-req/SKILL.md"
        ".claude/skills/harness-design/SKILL.md"
        ".claude/skills/harness-review/SKILL.md"
        ".claude/agents/doc-generator.md"
        ".claude/agents/reviewer.md"
        ".claude/agents/implementer.md"
        ".claude/agents/validator.md"
    )

    for f in "${required_files[@]}"; do
        if [ -f "$TARGET_DIR/$f" ]; then
            log_success "$f"
        else
            log_error "$f 缺失"
            errors=$((errors+1))
        fi
    done

    # 检查目录
    local required_dirs=(
        "team-knowledge/wiki"
        "team-knowledge/raw"
        "team-knowledge/schemas"
        "docs/versions/active"
    )

    for d in "${required_dirs[@]}"; do
        if [ -d "$TARGET_DIR/$d" ]; then
            log_success "$d/"
        else
            log_error "$d/ 缺失"
            errors=$((errors+1))
        fi
    done

    if [ $errors -gt 0 ]; then
        log_error "安装验证失败，发现 $errors 个错误"
        log_error "请检查问题或重新运行 init.sh"
        exit 1
    else
        log_success "所有关键文件就位"
    fi
}

# ============================================================
# 安装完成提示
# ============================================================
print_next_steps() {
    log_step "安装完成"

    echo ""
    echo "  🎉 安装成功！"
    echo ""
    echo "  📋 下一步："
    echo ""
    echo "  1. 检查 CLAUDE.md 渲染结果"
    log_info "     cat CLAUDE.md"
    log_info "     cat .claude/rules/tech-stack-rules.md"
    echo ""
    echo "  2. 验证 AI 是否加载规则"
    log_info "     claude"
    log_info "     > /clear"
    log_info "     > 介绍一下我们项目"
    echo ""
    echo "  3. 试跑第一个需求"
    log_info "     > /harness:req 我要做一个测试需求"
    echo ""
    echo "  🆘 遇到问题："
    log_info "     卸载：/path/to/harness-lite/scripts/uninstall.sh"
    log_info "     验证：/path/to/harness-lite/scripts/validate.sh"
    echo ""

    if [ "${INSTALL_HAD_BACKUP:-0}" = "1" ]; then
        log_info "原有文件已备份到：$BACKUP_DIR"
    fi

    log_info "Harness-Lite v$HARNESS_LITE_VERSION 已安装到 $TARGET_DIR"
    echo ""
}

# ============================================================
# 主流程
# ============================================================
main() {
    print_banner
    check_prerequisites
    detect_tech_stack
    interactive_tier
    interactive_project_info
    install_templates
    render_template_vars
    validate_installation
    print_next_steps
}

main "$@"
