# /harness-impact 报告 · v0.4-user-search

> 影响面分析（v1.0.25-final 修后版本：A3 排除自己 claim）

---

## 1. 本次改动文件

| 文件 | 改动类型 | 行数 |
|------|---------|------|
| src/services/search.py | 修改（追加 user_search 函数） | +5 |
| .claude/assignments/zoe.md | 修改（claim 状态更新） | +9 |

---

## 2. 直接依赖（调用了改动文件的模块）

| 依赖方 | 依赖内容 | 有测试？ |
|--------|---------|---------|
| src/api/user_api.py | 计划新增 `from search import user_search`（本次设计 §3.1） | ⚠️ 待加 |
| src/api/search_api.py | 已 `from search import basic_search`（alice v0.1） | ✅ tests/test_search.py |

---

## 3. 间接依赖

无（user_search 是新函数，未被其他模块依赖）

---

## 4. 测试覆盖

| 模块 | 测试 | 状态 |
|-----|------|------|
| basic_search（alice） | tests/test_search.py | ✅ 须不受本次改动破坏 |
| user_search（zoe，新） | tests/test_user_search.py | ⏳ 待 04-测试.md 写 |

---

## 🤝 协作冲突预警（A3 · v1.0.25-final 修后逻辑）

```python
overlap = 改动文件 ∩ (所有人 claim - 当前用户 claim)
        = {src/services/search.py, .claude/assignments/zoe.md}
        ∩ ({alice: search.py, search_api.py, test_search.py}
           ∪ {bob: user.py, profile.py})
        = {src/services/search.py}
```

⚠️ **真冲突 1 项**：

| 文件 | 冲突方 | 状态 | 建议 |
|------|--------|------|------|
| `src/services/search.py` | alice 在 v0.1-search-basic 中 claim | 阶段 3 编码中 | 与 alice 协作（本设计 D1 已采用复用方案） |

**自己 claim 不算冲突**（v1.0.25-final 修后逻辑）：
- zoe 自己也 claim 了 `src/services/search.py` → **不报告为冲突**
- 修复前会误报 zoe 自己冲突

---

## 🔍 协同视角（v1.0.23+）

### 📝 PM 视角（用户感知影响）
- 本次改动**不影响**用户已使用的 alice basic_search 行为（D1 复用方案保证）
- 新功能 user_search 暴露给前端需要 UI 配合（user_api.py 加 endpoint）
- 不需要发布说明（增量功能，无破坏性变更）

### 🧪 QA 视角（回归风险）
- ⚠️ **alice 的 tests/test_search.py 必须全部通过**——本次复用 basic_search 实现，破坏 basic_search = 同时破坏 v0.1 / v0.4
- ⚠️ **新增测试 tests/test_user_search.py**——覆盖 fields 参数 / 模糊匹配 / 边界
- ⚠️ **集成测试 user_api**——新 endpoint 需 Layer 2 测试

---

## 风险评估

🟡 **中风险**：
- alice 协调依赖（D1 复用方案需她同意）
- search.py 同时被 2 人改 → 必须严格按"先后 merge"或"并入 v0.1 多 owner"

---

## 建议下一步

1. **与 alice 沟通**：确认 D1 复用 basic_search 的方案
2. **任务模式选择**：[1] 拆分 / [2] 顺序 / [3] 多 owner（推荐）
3. 依据决定后进 03-代码索引.md 编码

---

*Harness-Lite v1.0.25-final · /harness-impact 真测产物*
