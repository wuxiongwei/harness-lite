---
name: interface-{{KEBAB_CASE_TITLE}}
description: {一句话描述这个接口}
type: interface
tags: [{tag1}, {tag2}]
date: {{DATE}}
related: [[相关接口]] [[相关决策]]
---

# 接口规范：{接口标题}

> **来源**：{{RAW_SOURCE_PATH}}
> **归档时间**：{{DATE}}
> **稳定度**：alpha / beta / stable / deprecated

---

## 1. 接口概述

- **业务用途**：（这个接口解决什么业务问题）
- **调用方**：（谁会调用这个接口）
- **被调用方**：（这个接口由谁实现）
- **调用频率**：（高 ≥ 100 QPS / 中 / 低）
- **可用性要求**：99% / 99.9% / 99.99%

---

## 2. 接口定义

### 2.1 协议

- 协议：HTTP REST / gRPC / Dubbo / MQ / 其他
- 路径：`{method} {path}`
- 认证：Token / Cookie / API Key / 无

### 2.2 请求

```yaml
method: POST
path: /api/v1/users
headers:
  Authorization: Bearer {token}
  Content-Type: application/json
body:
  name: string (required, 1-50字符)
  age: integer (optional, 默认0, 范围 0-150)
  email: string (optional, 必须符合 email 格式)
```

### 2.3 响应

#### 成功响应

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "u_123456",
    "name": "张三",
    "createTime": "2026-06-12T10:00:00+08:00"
  }
}
```

#### 错误响应

| code | 含义 | 处理建议 |
|------|------|---------|
| 4001 | 参数错误 | 检查请求参数 |
| 4011 | 未授权 | 重新获取token |
| 4031 | 无权限 | 联系管理员 |
| 4091 | 资源冲突 | 用户已存在 |
| 5001 | 服务异常 | 重试或联系开发 |

---

## 3. 字段口径

### 3.1 关键字段定义

| 字段 | 类型 | 含义 | 取值范围 | 注意事项 |
|------|------|-----|---------|---------|
| id | string | 用户唯一标识 | u_ + 6位数字 | 系统生成，不可改 |
| name | string | 用户名 | 1-50字符 | 不能含特殊字符 |
| age | integer | 年龄 | 0-150 | 默认 0 表示未知 |
| email | string | 邮箱 | RFC 5322 | 选填 |

### 3.2 跨端字段对齐（重要！）

> 五层契约：DB / Entity / SQL / ResultMap / DTO

| 层 | name 字段 | age 字段 |
|----|-----------|---------|
| DB | `users.name VARCHAR(50)` | `users.age TINYINT` |
| Entity | `private String name;` | `private Integer age;` |
| SQL | `SELECT name, age FROM users` | 同左 |
| ResultMap | `<result column="name" property="name"/>` | 同左 |
| DTO | `private String name;` | `private Integer age;` |

⚠️ 任一层缺字段 → 前端列空白

---

## 4. 调用示例

### 4.1 正常调用

```bash
curl -X POST https://api.example.com/api/v1/users \
  -H "Authorization: Bearer xxx" \
  -H "Content-Type: application/json" \
  -d '{"name": "张三", "age": 25}'
```

### 4.2 异常处理

```javascript
try {
  const response = await api.createUser({name: '张三', age: 25});
  if (response.code === 0) {
    // 成功
  } else if (response.code === 4091) {
    // 用户已存在，提示用户
  } else {
    // 其他错误
  }
} catch (e) {
  // 网络异常或500错误
}
```

---

## 5. SLA 与限制

- **响应时间**：P99 < 200ms
- **限流**：单用户 10 QPS
- **超时**：客户端建议设置 5 秒超时
- **重试**：可重试（幂等接口） / 不可重试

---

## 6. 兼容性约定

### 6.1 向后兼容承诺

- ✅ 新增可选字段 → 兼容
- ✅ 新增成功响应字段 → 兼容
- ❌ 删除字段 → **breaking change**
- ❌ 必填字段类型变化 → **breaking change**
- ❌ 错误码语义变化 → **breaking change**

### 6.2 版本演进

| 版本 | 时间 | 变更 |
|------|-----|------|
| v1.0 | 2026-06-12 | 首次发布 |
| v1.1 | （待定） | 增加 avatar 字段（可选） |

---

## 7. 注意事项

### 7.1 已知问题

- ⚠️ 当 age=0 时，前端展示为"未知"而不是"0岁"
- ⚠️ name 字段不支持特殊字符，但接口未做严格校验

### 7.2 性能注意

- 高并发场景下，后端有 Redis 缓存
- 缓存 TTL：5 分钟
- 强一致性场景：调用方需要带 `?nocache=true`

### 7.3 安全注意

- 接口已做 SQL 注入防护
- 敏感字段（如手机号）已脱敏
- 日志不会记录密码字段

---

## 关联

- 关联接口：[[相关接口1]] [[相关接口2]]
- 关联决策：[[为什么用这种契约]]
- 实现代码：path/to/UserController.java
- 调用方：path/to/UserClient.java
