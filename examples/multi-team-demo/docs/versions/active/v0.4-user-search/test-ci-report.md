# test-ci-report.md · v0.4-user-search

> 全量回归 + CI 质量门禁报告（dogfooding 模拟版）

---

## 执行信息

- 执行时间：2026-06-18 14:30
- 技术栈：Python（pytest）
- 测试框架：pytest 7.4

---

## Lint 结果

| 检查项 | 状态 | 问题数 |
|-------|------|-------|
| ruff check . | ✅ | 0 |

---

## 分层测试结果

### Layer 1 · 单元测试

```
tests/test_search.py::test_basic_search PASSED          # alice v0.1
tests/test_search.py::test_basic_search_empty PASSED    # alice v0.1
tests/test_search.py::test_basic_search_chinese PASSED  # alice v0.1
tests/test_user_search.py::test_user_search_by_name PASSED      # zoe v0.4 新
tests/test_user_search.py::test_user_search_by_email PASSED     # zoe v0.4 新
tests/test_user_search.py::test_user_search_invalid_field FAILED ← 失败！
```

- 总数：6
- 通过：5
- 失败：1
- 跳过：0
- 覆盖率：78%（⚠️ 目标 80%）

### Layer 2 · 集成测试

未执行（user_api endpoint 待编码）

### Layer 3 · E2E 测试

未执行（v0.4 阶段 4 才跑）

---

## 失败详情

### tests/test_user_search.py::test_user_search_invalid_field

```
错误：AssertionError: expected ValueError, got None
原因：fields 参数传入未知字段（如 ['unknown']）应抛 ValueError
推测根因：本次 user_search 实现遗漏 field 白名单校验
```

---

## 影响面分析（沿用 /harness-impact 输出）

- 改动：src/services/search.py（user_search 新增）
- 影响：user_api.py（待加 endpoint，本版本不验证）
- alice basic_search 单测 3 条**全部通过** ✅（D1 复用方案不破坏）

---

## 门控信号

```
状态: 🔴 BLOCKED
原因: tests/test_user_search.py::test_user_search_invalid_field 失败
建议: 返回 implementer 补 field 白名单校验后重跑
覆盖率次要警告: 78% < 80%（视作 P2 警告，不阻塞）
```

---

## 🔍 协同视角（v1.0.23+）

### 📝 PM 视角（用户场景覆盖）
- ⚠️ **未覆盖场景**：01-需求.md US1 验收标准"3 种搜索方式都返回正确结果"——当前测试只覆盖 name / email 2 种，**phone 未测**
- ⚠️ **覆盖率不足**：78% < 目标 80%，建议补 1-2 个边界用例（超长输入 / 中文）
- ✅ alice basic_search 测试全过——v0.4 不破坏 v0.1 用户感知

### 🛠️ RD 视角（实现假设）
- 🔴 **暴露设计假设错误**：02-设计.md 异常处理表只列了"空查询 / 超长 / 无结果 / 数据库超时"，**遗漏 fields 参数白名单校验**
- 修订建议：回到 02-设计.md §4 异常处理表加一行"fields 含未知字段 → 400 ValueError"
- 这是反向同步——principles §9 反馈回路驱动

---

## 🤝 协作冲突预警（A3 联动 · v1.0.25-final 修后）

```python
overlap = 改动文件 ∩ (所有人 claim - 当前用户 claim)
        = {src/services/search.py} ∩ {alice: search.py}
        = {src/services/search.py}
```

⚠️ alice 也在改 search.py（v0.1-search-basic）——本次测试已确认 alice 的 test_search.py 全过，复用方案 OK。

---

## 下一步

🔴 BLOCKED 处理：
1. 修复 user_search 加 field 白名单
2. 补 phone 字段单测 + 边界用例
3. 反向同步 02-设计.md 异常处理表
4. 重新运行 /harness-test-ci

---

*Harness-Lite v1.0.25-final · /harness-test-ci 真测产物*
