---
name: harness-prototype
description: |
  原型阶段 skill。基于 02-设计.md（或 01-需求.md）生成可交互 HTML 原型
  （Tailwind + Alpine.js），技术投入前先验证产品方向。纯前端单文件，零依赖。
  v1.0.32+ 从"可选触发"改为"默认必须"：/harness-design 通过后自动进入，
  用户可显式"跳过原型，直接编码"。仅纯后端 API / 改动极小 / 已有明确原型时跳过。
  典型触发：用户说"做个原型"、"prototype"、"mockup"、"demo"、"可交互界面"、
  "先看看长什么样"，或刚做完 /harness-design 进入编码前的原型验证。
---

# /harness-prototype · 原型生成 skill

> **路径A · 设计后默认环节**：把需求/设计翻译为可点击的 HTML 原型
> 让产品方向在写真代码前被看见、被验证、被推翻

---

## 定位

在"设计"和"编码"之间插入一个低成本验证环节。产出**可交互**的 HTML 原型（不是静态图），
让团队和客户在技术投入前确认产品方向，防止后续跑偏。

- 单 HTML 文件，Tailwind CDN + Alpine.js CDN，双击即开，无需构建
- 不接入真实数据，用示例数据模拟真实场景
- 验证完即可丢弃，原型不是生产代码

**v1.0.32+ 设计变更**：原型从"可选触发"改为"默认必须"。
- /harness-design 通过后，**默认进入本 skill**
- 用户可显式跳过（说"跳过原型，直接编码"）
- 跳过仅适用于：纯后端 API（无前端交互）/ 改动极小（应走路径 B）/ 已有明确原型设计稿

**为什么默认必须**：
- MVP / 新产品最大风险是"写完才发现方向错了"，原型成本低（5-10 分钟生成 + 验证）
- 用户在浏览器实际体验流程，比看设计文档更容易发现问题
- 原型验证通过后，编码时有具体参照，开发效率反而更高
- 来源：v1.0.31 实战反馈——旧"可选"设计导致执行者从设计直接跳编码，漏掉验证环节

**何时用**：路径A 完成 02-设计后**默认进入**——这是设计与编码之间的标准环节，不需要特殊触发。
**何时跳过**：用户明确说"跳过原型"，且属于以下场景之一——纯后端 API（无前端交互）/ 改动极小（应走路径B）/ 已有明确原型设计稿。路径B/C（小需求、bug 修复）本就不进原型。

---

## Phase 1：输入识别

按优先级查找输入源（对齐 harness 产物链路）：

```
1. 优先 Read：当前版本目录的 02-设计.md
2. 次选 Read：01-需求.md（无设计时）
3. 都没有：让用户一句话描述产品，降级为"口述需求 → 原型"
```

从输入中提取（Claude 直接读，不用正则）：

| 提取项 | 来源 | 用途 |
|--------|------|------|
| 产品名称 | 标题 / 需求首段 | 原型标题栏 |
| 核心功能 | must_haves / 功能需求（F-XXX） | 决定页面与交互 |
| 用户角色 | 用户角色 / Persona 章节 | 决定视角与权限展示 |
| 关键页面 | 从功能推断（3-5 个） | 原型页面骨架 |

> 找不到版本目录时，先问用户当前在哪个 `docs/versions/active/v{X.Y.Z}-{slug}/`，
> 不要静默猜测路径。

---

## Phase 2：模板与产出位置

```
产出目录：docs/versions/active/v{X.Y.Z}-{slug}/prototype/
├── prototype.html          # 可交互原型（单文件）
└── prototype-spec.md       # 交互规格说明
```

目录不存在 → 创建。版本目录无法确定 → 停止并询问用户。

---

## Phase 3：subagent 调度（生成原型 · 两步独立）

> ⚠️ **拆成两个独立 subagent，先 spec 后 HTML。** 实测发现：单个 subagent
> 同时产 HTML + spec 时，长任务中途若连接中断，会丢掉还没写的产物。
> 拆开后一个挂了不影响另一个，且 spec 先行能为 HTML 提供结构蓝图。

### Step 1：doc-generator 写交互规格（先做，轻量，快）

```
Task(
  subagent_type: "doc-generator",
  description: "写原型交互规格",
  prompt: """
    基于 docs/versions/active/v{X}-{slug}/02-设计.md（或 01-需求.md），
    写交互规格到 docs/versions/active/v{X}-{slug}/prototype/prototype-spec.md。

    === 章节 ===
    - 页面结构（Header / Sidebar / Content）
    - 导航流程（页面跳转逻辑）
    - 数据展示（表格 / 卡片 / 图表）
    - 表单交互（输入 / 提交 / 验证）
    - 响应式断点（移动端 / 桌面端）

    至少 100 行。完成后报告文件路径 + 行数（wc -l 实测）。
  """
)
```

### Step 2：implementer 写可交互 HTML（基于 spec）

```
Task(
  subagent_type: "implementer",
  description: "生成可交互 HTML 原型",
  prompt: """
    你是 UI/UX 设计师。基于 docs/versions/active/v{X}-{slug}/02-设计.md
    和已生成的 prototype-spec.md，生成可交互的 HTML 原型。

    输出文件：docs/versions/active/v{X}-{slug}/prototype/prototype.html

    === 硬性要求 ===
    - Tailwind CSS（CDN）+ Alpine.js（CDN）
    - 响应式（移动端 + 桌面端）
    - 包含 3-5 个核心页面，用 Alpine.js x-show 切换导航
    - 每个页面含示例数据（模拟真实场景，不留空白占位）
    - 至少 300 行，含完整交互（点击、切换、表单）
    - 单文件，双击可在浏览器直接打开

    === 执行步骤 ===
    1. Read 02-设计.md + prototype-spec.md 了解功能与交互细节
    2. Write prototype.html（≥300 行，含完整交互）
    3. 完成后报告：文件路径 + 行数（wc -l），并报告
       grep -c 'x-show'（页面数 ≥3）/ grep -c '@click'（交互点 ≥3）
       / grep -c 'cdn'（CDN 引用 =2）

    === 禁止 ===
    - 不接真实后端 / API（用示例数据）
    - 不引入需求/设计没提的功能
    - 不留 TODO 空白页（每页必须有可看的内容）
  """
)
```

> 若 Step 2 中断：spec 已安全落盘，重跑 Step 2 即可，无需从头再来。

### HTML 骨架参考（喂给 subagent，确保结构一致）

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{产品名} - 原型</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body x-data="app()" class="bg-gray-50">
  <nav class="bg-blue-600 text-white p-4 flex justify-between items-center">
    <h1 class="text-xl font-bold">{产品名}</h1>
    <div class="space-x-4">
      <button @click="page='dashboard'" :class="page==='dashboard' ? 'underline' : ''">首页</button>
      <!-- 更多导航按钮 -->
    </div>
  </nav>
  <div class="container mx-auto p-6">
    <div x-show="page==='dashboard'">
      <h2 class="text-2xl font-bold mb-4">Dashboard</h2>
      <!-- 内容 -->
    </div>
    <!-- 其他页面 -->
  </div>
</body>
<script>
function app() {
  return {
    page: 'dashboard',
    data: []   // 示例数据
  }
}
</script>
</html>
```

---

## Phase 4：反向校验追问

subagent 完成后，主 skill 追问（对齐 harness-design 的反向校验风格）：

```
1. "原型覆盖了 02-设计/01-需求 的哪几个核心功能？逐条对应"
2. "有没有做需求没要求的页面或交互？（越界检查）"
3. "每个页面都有可看的示例数据吗？有没有空白占位页？"
4. "原型用一句话概括，验证的是哪个产品假设？"
```

---

## Phase 5：自检 + 截图回读（硬门禁 · principles §16）

不跑 Python 验证器，但**截图回读是硬门禁**——这是 §16 交付前自测铁律对页面类产物的标准动作。

```
[ ] 1. HTML 文件存在且 ≥ 300 行（Bash: wc -l）
[ ] 2. 含 Tailwind CDN + Alpine.js CDN 两个 script 标签
[ ] 3. Alpine 语法正确（x-data / x-show / @click 成对，无明显拼写错）
[ ] 4. 覆盖 3-5 个核心页面，页面间可切换
[ ] 5. 每页有示例数据，无 TODO 空白页
[ ] 6. prototype-spec.md 存在且含 5 个规格章节
[ ] 7. 🔴 截图回读通过（见下方 · 不做 = 没自测 = 不可交付）
```

### 截图回读（必做硬门禁 · 替代旧的"open 一下就声称可用"）

> ⚠️ **v1.0.33 强约束**：v1.0.31-32 翻车根因——AI 跑 `open xxx.html` 拿到 exit 0
> 却看不到渲染画面，脑补"应该没问题"就交付，用户一上手第一个就崩。
> 现在**必须截图 + Read 回读，AI 真的看到渲染结果**才算自测过。

```bash
# 1. headless Chrome 渲染并截图（路径按平台探测）
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || CHROME="$(command -v google-chrome || command -v chromium || command -v chrome)"
PROTO="docs/versions/active/v{X}-{slug}/prototype/prototype.html"
"$CHROME" --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --screenshot="/tmp/proto-selftest.png" --window-size=1440,900 \
  "file://$(pwd)/$PROTO"
ls -la /tmp/proto-selftest.png   # 确认截图生成
```

```
# 2. 用 Read 工具读 /tmp/proto-selftest.png —— 真的看渲染结果
# 3. 判读（对照 02-设计/01-需求 的核心功能）：
#    - 页面渲染出来了吗？还是白板？
#    - 关键元素在吗（标题栏 / 导航 / 核心内容区）？
#    - 布局崩没崩？文字溢出 / 元素重叠？
#    - 示例数据显示了吗？
# 4. 有问题 → 委托 implementer 修 → 回到第 1 步重新截图，直到画面干净
# 5. （可选增强）切到第 2/3 个页面再各截一张，确认导航后页面也正常
#    —— 改 HTML 里 x-data 初始 page 值或用 Playwright，按需
```

⚠️ **截图能挡"第一眼就崩"（白板 / JS 报错 / 布局烂），挡不住"点到第三步才崩"的深层交互。**
若需覆盖交互链路，升级 Playwright（模拟点击 + 抓 console error）。当前默认档：截图回读首屏 + 可选多页截图。

> grep 兜底（无浏览器环境时）：`grep -c 'x-show'`（≥3）/ `grep -c '@click'`（≥3）/ `grep -c 'cdn'`（=2）。
> 但 grep 只验结构存在、**不验渲染**——能用截图就别只 grep，并明确告诉用户"未做截图回读"。

---

## Phase 6：流转建议

```
✅ 自检全过 + 截图回读确认渲染正常（§16 硬门禁）：
   → 提示用户："原型已就绪，我已截图自测确认渲染正常，请打开 prototype.html 验证产品方向"
   → （建议把自测截图一并给用户看，眼见为实）
   → 用户确认方向 OK → 回到编码（/harness-design 已完成则进 implementer）
   → 用户看完要调整 → 局部修订原型（不重写整个文件）→ 改完重新截图回读
   → 用户看完发现方向错了 → 回到 /harness-req 或 /harness-design 重审

🔴 截图回读发现白板 / 渲染崩 / 空白页 / 交互缺失：
   → 这是阻塞（§16 + §7）→ 委托 implementer 修 → 重新截图回读
   → 修好前**不允许**提示用户"已就绪"

🔴 反复修订 > 3 轮：
   → 可能是需求/设计本身不清晰
   → 建议回到 02-设计.md 重新对齐
```

---

## 错误处理

### 找不到 02-设计.md 和 01-需求.md
```
降级：让用户一句话描述产品（产品名 + 核心功能 + 用户角色），
基于口述生成原型。提示用户"建议先走 /harness-req 沉淀需求"。
```

### 版本目录无法确定
```
停止，询问用户当前版本目录路径，不静默猜测。
```

### 原型反复修订（>3轮）
```
报错："原型反复修订超过 3 轮，可能需求/设计本身方向不清晰"
建议：回到 /harness-design 重新对齐方向
```

---

## 使用示例

```
用户：/harness-prototype

skill 行动：
  1. Read 当前版本目录的 02-设计.md（提取产品名/功能/角色/页面）
  2. 创建 prototype/ 目录
  3. 委托 implementer 生成 prototype.html + prototype-spec.md
  4. 反向校验（覆盖度 / 越界 / 空白页 / 假设）
  5. 自检 + 截图回读（headless 截图 → Read 看渲染 → 有问题修了重截）
  6. 提示用户：原型已就绪（附自测截图），打开验证产品方向
```

---

*Harness-Lite · /harness-prototype · 路径A 设计后默认环节（v1.0.32+，可显式跳过）· 提取自 ccflow prototype workflow*

