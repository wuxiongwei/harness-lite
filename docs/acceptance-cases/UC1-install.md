# UC1 安装类验收用例

> 验证目标：30分钟建立AI协作共识

---

## UC1.1 新项目安装（静态）

### 验收标准

`init.sh` 在空目录跑通，生成完整目录结构，耗时 < 5分钟。

### 验证步骤（脚本自动）

```bash
# 1. 创建临时测试目录
TEST_DIR=/tmp/harness-test-$(date +%s)
mkdir -p $TEST_DIR

# 2. 执行安装脚本
cd $TEST_DIR
./scripts/init.sh --no-interactive

# 3. 检查目录结构
check_structure() {
  test -f CLAUDE.md || fail "CLAUDE.md 未生成"
  test -d .claude/skills/ || fail ".claude/skills/ 目录缺失"
  test -d .claude/agents/ || fail ".claude/agents/ 目录缺失"
  test -d .claude/rules/ || fail ".claude/rules/ 目录缺失"
  test -f .claude/settings.json || fail ".claude/settings.json 未生成"
  test -d docs/versions/active/ || fail "docs/versions/active/ 目录缺失"
  test -d team-knowledge/wiki/ || fail "team-knowledge/wiki/ 目录缺失"
}

# 4. 检查文件数量
count_skills=$(ls .claude/skills/ | wc -l)
test $count_skills -ge 3 || fail "skill 数量不足（应有 ≥3，实际 $count_skills）"

# 5. 清理
rm -rf $TEST_DIR
```

### 通过条件

- 所有目录结构检查通过
- skill 数量 ≥ 3
- 无报错退出

---

## UC1.2 CLAUDE.md 自动加载（行为）

### 验收标准

`/clear` 后会话开始，AI 自动读取 CLAUDE.md + 3份规则（principles/tech-stack-rules/domain-rules）。

### 验证步骤（手动）

1. 在已安装项目启动 Claude Code
2. 执行 `/clear` 清空会话
3. 观察 AI 是否：
   - 自动加载 CLAUDE.md（可在 system prompt 中看到）
   - 知道项目的技术栈（从 tech-stack-rules.md）
   - 知道核心约束（从 principles.md）

### 验证 prompt

```
请问你当前知道：
1. 这个项目的技术栈是什么？
2. AI编码的核心铁律有哪些？
3. 团队的业务铁律有哪些？
```

### 通过条件

- AI 能回答技术栈（说明 tech-stack-rules.md 已加载）
- AI 能说出 ≥5 条铁律（说明 principles.md 已加载）
- AI 能说出业务约束（说明 domain-rules.md 已加载）

---

*Harness-Lite · UC1 安装类验收用例 · v1.0.35*