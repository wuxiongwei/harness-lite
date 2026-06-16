#!/bin/bash
# Harness-Lite · pre-commit-test.sh
# 在 git commit 前自动运行全量测试，防止破坏性提交
#
# 配置方式（由 init.sh 自动写入 settings.json）：
#   "hooks": {
#     "PreToolUse": [{"matcher": "Bash", "matchGlob": "git commit*",
#                     "command": "bash .claude/hooks/pre-commit-test.sh"}]
#   }
#
# 如需禁用（临时）：设置环境变量 HARNESS_SKIP_TEST=1
# 如需定制：修改本文件 "项目定制区" 部分

set -e

# ── 颜色 ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log_ok()   { echo -e "${GREEN}✓${NC}  $1"; }
log_err()  { echo -e "${RED}✗${NC}  $1" >&2; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }

# ── 快速跳过开关 ──────────────────────────────────────
if [ "${HARNESS_SKIP_TEST:-0}" = "1" ]; then
    log_warn "HARNESS_SKIP_TEST=1，跳过全量测试（仅限紧急情况）"
    exit 0
fi

echo ""
echo "━━━ Harness-Lite: 全量回归测试 ━━━"

# ── 切换到项目根目录 ──────────────────────────────────
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# ── 技术栈检测 ────────────────────────────────────────
detect_stack() {
    if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "setup.cfg" ]; then
        echo "python"
    elif [ -f "pom.xml" ]; then
        echo "java-maven"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java-gradle"
    elif [ -f "package.json" ]; then
        # 区分 Node.js 后端项目和前端工具链
        if grep -q '"test"' package.json 2>/dev/null; then
            echo "nodejs"
        else
            echo "nodejs-no-test"
        fi
    elif [ -f "go.mod" ]; then
        echo "go"
    else
        echo "unknown"
    fi
}

STACK=$(detect_stack)
log_info "检测到技术栈：$STACK"

# ── 运行测试 ──────────────────────────────────────────
run_tests() {
    case "$STACK" in
        python)
            if command -v pytest &>/dev/null; then
                log_info "运行：pytest tests/ -x -q --tb=short"
                pytest tests/ -x -q --tb=short
            else
                log_warn "pytest 未安装，跳过测试"
                return 0
            fi
            ;;
        java-maven)
            log_info "运行：mvn test -q"
            mvn test -q
            ;;
        java-gradle)
            log_info "运行：./gradlew test -q"
            ./gradlew test -q
            ;;
        nodejs)
            log_info "运行：npm test"
            npm test
            ;;
        go)
            log_info "运行：go test ./..."
            go test ./... -count=1
            ;;
        nodejs-no-test)
            log_warn "package.json 未配置 test script，跳过"
            return 0
            ;;
        unknown)
            log_warn "无法识别测试框架，跳过（在 .claude/hooks/pre-commit-test.sh 的定制区配置）"
            return 0
            ;;
    esac
}

# ── Lint 检查（非阻塞，只警告）──────────────────────────
run_lint() {
    case "$STACK" in
        python)
            if command -v ruff &>/dev/null; then
                log_info "Lint：ruff check . --select=E,W,F --ignore=E501"
                ruff check . --select=E,W,F --ignore=E501 && \
                    log_ok "Lint 通过" || log_warn "Lint 有警告，非阻塞"
            fi
            ;;
        java-maven)
            # Checkstyle 在 mvn test 中通常已包含，这里跳过
            ;;
        nodejs)
            if grep -q '"lint"' package.json 2>/dev/null; then
                npm run lint --if-present && \
                    log_ok "Lint 通过" || log_warn "Lint 有警告，非阻塞"
            fi
            ;;
    esac
}

# ── 覆盖率检查（可选，按阈值阻断）──────────────────────
# 默认关闭，在项目定制区启用
check_coverage() {
    local threshold="${HARNESS_COVERAGE_THRESHOLD:-0}"
    if [ "$threshold" = "0" ]; then
        return 0
    fi

    log_info "检查覆盖率（阈值：${threshold}%）..."
    case "$STACK" in
        python)
            pytest tests/ -q --cov=. --cov-fail-under="$threshold" \
                --cov-report=term-missing -q 2>/dev/null || {
                log_err "覆盖率低于 ${threshold}%"
                return 1
            }
            ;;
    esac
}

# ══════════════════════════════════════════════
#  项目定制区（init.sh 不覆盖此区域）
#  在这里覆盖上面的函数或添加额外检查
#
#  例 1：设置覆盖率阈值
#    export HARNESS_COVERAGE_THRESHOLD=70
#
#  例 2：跳过特定测试目录
#    PYTEST_ADDOPTS="--ignore=tests/slow" run_tests
#
#  例 3：同时跑前后端测试
#    run_tests
#    cd frontend && npm test && cd ..
#
# ══════════════════════════════════════════════

# ── 主流程 ────────────────────────────────────────────
FAILED=0

run_lint  # lint 不阻塞

run_tests || FAILED=1

if [ "${HARNESS_COVERAGE_THRESHOLD:-0}" != "0" ]; then
    check_coverage || FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    log_ok "全量测试通过，允许 commit"
    echo ""
    exit 0
else
    log_err "全量测试失败，commit 已阻止"
    log_info "修复后重新 commit，或设置 HARNESS_SKIP_TEST=1 临时跳过（仅限紧急）"
    echo ""
    # exit 2 = Claude Code PreToolUse 阻塞约定（stderr 反馈给 AI）
    echo "🔴 全量测试失败，commit 被阻止。修复后重试，或 HARNESS_SKIP_TEST=1 临时跳过。" >&2
    exit 2
fi
