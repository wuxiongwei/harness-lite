---
name: architecture-{{KEBAB_CASE_TITLE}}
description: {一句话描述这个架构}
type: architecture
tags: [{tag1}, {tag2}]
date: {{DATE}}
related: [[相关架构]] [[相关决策]]
---

# 架构：{架构标题}

> **来源**：{{RAW_SOURCE_PATH}}
> **归档时间**：{{DATE}}
> **范围**：{整体系统 / 子系统 / 模块}

---

## 1. 架构概述

```
（用一段话讲清楚这个架构是做什么的）

例如：
本架构描述用户中心子系统（UC），负责用户注册、登录、资料管理、
权限控制等核心功能。基于 Spring Boot + MySQL + Redis，
通过 Dubbo 对外提供 RPC 接口。
```

### 部署形态

- **应用形态**：（单体 / 微服务 / Serverless / ...）
- **部署位置**：（独立部署 / 与XX同部署）
- **数据源**：（哪些DB / 哪些缓存 / 哪些MQ）
- **对外接口**：（HTTP / RPC / MQ / ...）

---

## 2. 模块结构

```
（用 ASCII 图或文字描述模块关系）

UC（用户中心）
├── uc-api          # 对外接口模块
│   ├── HTTP REST API
│   └── Dubbo RPC API
├── uc-core         # 核心业务模块
│   ├── UserService
│   ├── AuthService
│   └── PermissionService
├── uc-storage      # 数据存储模块
│   ├── MySQL Mapper
│   └── Redis Cache
└── uc-common       # 公共工具
```

### 模块职责表

| 模块 | 职责 | 技术栈 | 依赖 |
|------|------|-------|------|
| uc-api | 对外接口 | Spring MVC / Dubbo | uc-core |
| uc-core | 业务逻辑 | Spring | uc-storage |
| uc-storage | 数据访问 | MyBatis / Redis | - |
| uc-common | 工具类 | - | - |

---

## 3. 数据流

### 3.1 主流程：用户登录

```
[Client] 
   ↓ POST /api/login
[uc-api/AuthController]
   ↓ AuthService.login()
[uc-core/AuthService]
   ↓ 1. 校验密码
[uc-storage/UserMapper]  → MySQL
   ↓ 2. 生成 Token
[uc-storage/TokenCache]  → Redis
   ↓ 3. 返回结果
[Client]
```

### 3.2 主流程：权限校验

```
（其他重要数据流）
```

---

## 4. 关键设计决策

> 为什么这样设计？这是未来重构时最重要的参考

### 4.1 决策1：选用 Dubbo 而非 gRPC

- **背景**：（当时面临什么问题）
- **选项**：Dubbo / gRPC / HTTP REST
- **选择**：Dubbo
- **原因**：
  - 团队 Java 主力，Dubbo 生态对接成熟
  - 内部已有 Dubbo 治理平台
  - gRPC 跨语言优势在内部不需要
- **关联决策**：[[详细决策记录]]

### 4.2 决策2：Token 存 Redis 而非 JWT

- **背景**：
- **选项**：
- **选择**：
- **原因**：
- **关联决策**：[[]]

### 4.3 决策N：...

---

## 5. 数据模型

### 5.1 核心表

```sql
-- 用户表
CREATE TABLE users (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(200) NOT NULL,
    email VARCHAR(100),
    create_time TIMESTAMP NOT NULL,
    update_time TIMESTAMP NOT NULL,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- 角色表
CREATE TABLE roles (...);

-- 用户角色关联表
CREATE TABLE user_roles (...);
```

### 5.2 缓存设计

| 缓存 Key | 用途 | TTL | 一致性策略 |
|---------|------|-----|----------|
| `user:{id}` | 用户信息 | 5min | 写时删除 |
| `token:{token}` | Token 验证 | 24h | 强一致 |
| `permissions:{userId}` | 权限缓存 | 10min | 写时刷新 |

---

## 6. 集成点

### 6.1 上游依赖（被谁调用）

- 业务A → 调用 UC 的登录接口
- 业务B → 调用 UC 的权限校验
- 业务C → 调用 UC 的用户信息查询

### 6.2 下游依赖（调用谁）

- MySQL：用户主数据
- Redis：缓存 + Token
- MessageBus：用户事件广播
- LDAP：（如有）外部认证源

---

## 7. 非功能要求

### 7.1 性能

| 接口 | P99 响应时间 | QPS |
|------|------------|-----|
| 登录 | < 200ms | 1000 |
| 权限校验 | < 50ms | 5000 |
| 用户查询 | < 100ms | 2000 |

### 7.2 可用性

- SLA：99.9%
- 灾备：跨可用区主备
- 降级方案：Token 校验失败时降级为 JWT 模式

### 7.3 安全

- 密码：BCrypt 加盐
- Token：32位随机字符串
- 敏感日志：自动脱敏

---

## 8. 演进历史

| 时间 | 版本 | 重大变更 |
|------|------|---------|
| 2024-01 | v1.0 | 初版上线，单体架构 |
| 2024-08 | v2.0 | 拆分为微服务 |
| 2025-03 | v2.5 | 引入 Redis 缓存 |
| 2026-06 | v3.0 | 当前版本，引入 SSO |

---

## 9. 已知问题与改进方向

### 已知问题

- ⚠️ 高并发场景下，权限缓存可能不一致
- ⚠️ Token 续期逻辑复杂

### 改进方向

- v4.0 计划：迁移到 Service Mesh
- v4.1 计划：支持多租户

---

## 关联

- 关联架构：[[父架构-整体系统]] [[子架构-AuthSubsystem]]
- 关联决策：[[为什么选Dubbo]] [[为什么用Redis]]
- 关联陷阱：[[历史踩过的并发坑]]
- 实现代码：`src/main/java/com/example/uc/`
