---
name: pitfall-{{KEBAB_CASE_TITLE}}
description: {一句话描述这个陷阱}
type: pitfall
tags: [{tag1}, {tag2}]
date: {{DATE}}
related: [[相关陷阱]] [[相关决策]]
---

# 陷阱：{一句话标题}

> **来源**：{{RAW_SOURCE_PATH}}（事故报告/Bug记录/复盘等）
> **归档时间**：{{DATE}}
> **关联需求**：v{{VERSION}}-{{SLUG}}

---

## 1. 触发场景

```
什么操作 / 什么条件下踩坑
（具体到代码行为，不要抽象）

例如：
- 用户在购物车界面快速点击"提交订单"按钮（点击间隔 < 500ms）
- 系统并发处理两次订单创建请求
- 两次请求都通过了余额校验
- 最终扣了一次钱，但创建了两个订单
```

## 2. 根因分析

### 2.1 表层原因（What发生了什么）

```
代码层面发生了什么？

例如：
ConcurrentModification 导致两个请求同时通过校验
```

### 2.2 底层原因（Why为什么发生）

```
为什么会发生？

例如：
缺少分布式锁，校验和扣款不是原子操作
```

### 2.3 设计/流程缺陷（Why-Why）

```
为什么"为什么会发生"会发生？

例如：
- 当时设计阶段没考虑高并发场景
- 团队没有"金额操作必须加锁"的规范
- Code Review 没有这个检查项
```

---

## 3. 后果与影响

### 影响范围

- **用户影响**：（多少用户受影响 / 怎么影响）
- **数据影响**：（产生多少脏数据 / 是否能恢复）
- **系统影响**：（是否影响其他模块）
- **业务影响**：（资金损失 / 投诉 / 合规风险）

### 修复成本

- **发现到修复**：{{HOURS}}小时
- **修复涉及人员**：{{PEOPLE}}人
- **是否需要数据修复**：（是 → 修复脚本：xxx / 否）

---

## 4. 修复方式

### Before（错误写法）

```language
// 路径：path/to/file.{ext}:line
// ❌ 错误代码
public void deductBalance(Long userId, BigDecimal amount) {
    User user = userMapper.selectById(userId);
    if (user.getBalance().compareTo(amount) < 0) {
        throw new BusinessException("余额不足");
    }
    user.setBalance(user.getBalance().subtract(amount));
    userMapper.updateById(user);
}
```

### After（正确写法）

```language
// ✅ 正确代码
public void deductBalance(Long userId, BigDecimal amount) {
    String lockKey = "balance:lock:" + userId;
    try {
        if (!redisLock.tryLock(lockKey, 5, TimeUnit.SECONDS)) {
            throw new BusinessException("操作过于频繁");
        }
        // 加锁后再校验+扣款
        User user = userMapper.selectById(userId);
        if (user.getBalance().compareTo(amount) < 0) {
            throw new BusinessException("余额不足");
        }
        user.setBalance(user.getBalance().subtract(amount));
        userMapper.updateById(user);
    } finally {
        redisLock.unlock(lockKey);
    }
}
```

### 关键差异

- 增加了什么：分布式锁
- 为什么这么改：保证校验+扣款的原子性

---

## 5. 预防规则（关键！）

### 5.1 是否需要进 CLAUDE.md 规则？

- [ ] 通用语法层面 → 加到 `principles.md`
- [ ] 技术栈陷阱 → 加到 `tech-stack-rules.md`
- [ ] 业务铁律 → 加到 `domain-rules.md`
- [ ] 不需要进规则（仅记录） → 跳过

### 5.2 建议规则条款

```markdown
（如果上面任一为是，给出具体规则条款）

例如：
### 金额操作必须加锁
- **要求**：涉及余额/库存/积分的写操作必须加分布式锁
- **来源**：[[此陷阱]]
- **检查点**：所有 deduct/add/transfer 类方法
- **示例**：见上面的"After"
```

### 5.3 是否需要 Code Review 检查清单？

- [ ] 是 → 在Code Review清单加："涉及金额操作的方法是否加锁？"
- [ ] 否 → 跳过

### 5.4 是否需要自动化检查（lint/static analysis）？

- [ ] 可以做静态检查 → 工具：（如 SpotBugs / ESLint plugin）
- [ ] 暂不能做 → 依赖人工 Review

---

## 6. 团队同步

- [ ] 已在站会同步给团队
- [ ] 已加入新人 onboarding 材料
- [ ] 已通知相关模块负责人

---

## 7. 类似问题排查

> 当前修了 X，是否还有其他地方有同样问题？

| 文件/位置 | 是否有同样问题 | 处理 |
|---------|-------------|------|
| path1 | 有 | 已修 |
| path2 | 有 | 已修 |
| path3 | 无 | - |

---

## 关联

- 关联 pitfalls：[[相关陷阱1]] [[相关陷阱2]]
- 关联 decisions：[[相关技术决策]]
- 关联代码模块：path/to/module
