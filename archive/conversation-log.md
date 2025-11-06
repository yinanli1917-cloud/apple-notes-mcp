# 苹果备忘录智能搜索 MCP - 对话记录

**创建时间**: 2025-11-04
**项目目标**: 创建 MCP 服务器，实现苹果备忘录的自动导出、语义搜索和 iMessage 交互

---

## 用户需求概述

**背景信息**:
- 编程零基础
- 硬件：M2 Max Mac Studio
- 备忘录数量：近千条，极少数图片
- 不介意隐私，可以使用云服务
- 主要目标：定位备忘录内容，支持写作和第二大脑

**核心需求**:
1. 自动导出苹果备忘录（带特定 tag）到 Markdown
2. 实现模糊语义搜索（不是精确匹配）
3. 支持多步搜索（AI 边思考边搜索，可以二次搜索）
4. 接入 Poke 实现 iMessage 交互
5. 集成 DeepSeek V3 Thinking API

**现有痛点**:
- Claude 现在是随机选取 50 篇备忘录再搜索
- 需要像 agent 一样先搜索哪些可能包含相关内容
- 然后核对定位到具体哪一篇的哪些内容

**关于 Obsidian 插件**:
- 用户发现 Obsidian 有导出插件
- 希望自动化这个流程

**部署偏好**:
- 不想本地部署（误解已澄清：实际是指不想云部署，本地 M2 Max 性能充足）
- Poke 部分已解决，只需 MCP 搞定即可接入
- 图片处理优先级低，可后期加 OCR
- 全部自己实现（DIY 精神）

---

## 研究发现摘要

### 1. Obsidian 插件调研
- **官方插件**: obsidian-importer
- **工作原理**: 直接访问 Apple Notes SQLite 数据库
- **局限**: 仅支持一次性手动导入，不适合自动化

### 2. 推荐方案：apple-notes-to-sqlite
- **优势**: 命令行工具，易于自动化
- **技术**: 基于 AppleScript (osascript)
- **输出**: 干净的 SQLite 数据库
- **限制**: 纯文本，不含附件位置信息

### 3. 向量搜索技术栈
**ChromaDB** (推荐):
- 轻量级，纯 Python
- 1000 条笔记下性能充足（~20ms 查询）
- 自动管理嵌入

**FastEmbed** (嵌入模型):
- 无需 PyTorch，节省空间
- CPU 优化，适合 M2 Max
- 默认模型：BGE-small-en-v1.5 (384维)

### 4. MCP 服务器开发
**FastMCP** (推荐框架):
- Python SDK，初学者友好
- 简单装饰器语法 (`@mcp.tool()`)
- 支持 stdio 和 SSE 传输

**关键工具设计**:
- `search_notes(query, limit)`: 语义搜索
- `refine_search(query, filters)`: 精细化搜索
- `refresh_index()`: 手动刷新索引

### 5. DeepSeek V3 API
- ✅ **确认支持 function calling**
- OpenAI 兼容 API
- 价格极低：$0.07-1.68 / 百万 tokens
- 两种模式：deepseek-chat / deepseek-reasoner

### 6. Poke 集成
- 支持 MCP 通过 SSE/HTTP 传输
- 需要 HTTPS 端点（可用 Cloudflare Tunnel）
- 已有 iMessage 接口，只需对接 MCP

### 7. 自动化方案
**fswatch** (文件监控):
- macOS 原生，brew 安装
- 监控 Apple Notes 数据库变化
- 触发自动导出和重新索引

**launchd** (后台服务):
- 开机自启动
- 故障自动重启
- 比 cron 更适合 macOS

---

## 技术架构图

```
┌─────────────────────────┐
│   Apple Notes App       │
│   (SQLite Database)     │
└───────────┬─────────────┘
            │ fswatch 监控
            ▼
┌─────────────────────────┐
│  apple-notes-to-sqlite  │
│  导出到 ~/notes.db      │
└───────────┬─────────────┘
            │ Python 脚本读取
            ▼
┌─────────────────────────┐
│      ChromaDB           │
│  (向量数据库)           │
│  FastEmbed 嵌入模型     │
└───────────┬─────────────┘
            │ MCP Protocol
            ▼
┌─────────────────────────┐
│    FastMCP Server       │
│  - search_notes()       │
│  - refine_search()      │
│  - refresh_index()      │
└───────────┬─────────────┘
            │ stdio / SSE
            ▼
┌─────────────────────────┐
│  Poke AI (iMessage)     │
│  + DeepSeek V3 API      │
└─────────────────────────┘
```

---

## 5周实施计划

### 第1周：环境搭建
- 安装 Python 依赖
- 测试 apple-notes-to-sqlite
- 创建项目目录结构

### 第2周：向量搜索
- 搭建 ChromaDB 索引
- 实现增量更新
- 测试语义搜索

### 第3周：MCP 开发
- 创建 FastMCP 服务器
- 实现搜索工具
- Claude Desktop 测试

### 第4周：自动化
- 配置 fswatch 监控
- 设置 launchd 服务
- 日志和监控

### 第5周：Poke 集成
- 暴露 SSE 端点
- Poke 配置
- 端到端测试

---

## 关键决策点

### 为什么不用 WeKnora？
- 对于 1000 条笔记，ChromaDB 足够
- WeKnora 是企业级方案，配置复杂
- 零基础用户更适合轻量方案

### 为什么本地部署？
- M2 Max 性能充足（用户已有）
- 无月费（除 DeepSeek API ~$5-10）
- 完全隐私（虽然用户不介意）

### 多步搜索如何实现？
```python
# 流程示例
用户: "找机器学习项目笔记"
→ search_notes("机器学习 项目")
→ DeepSeek 分析结果
→ refine_search("机器学习 深度学习", date="2025")
→ 返回精准结果
```

---

## 潜在挑战

### 1. 标签筛选
**问题**: apple-notes-to-sqlite 不直接支持按标签导出
**解决**:
- 导出全部，在元数据中保存标签
- 搜索时通过 ChromaDB 的 `where` 过滤
- 或使用 Smart Folders 预筛选

### 2. AppleScript 权限
**问题**: 可能被拒绝访问
**解决**: 系统设置 → 完全磁盘访问 → 添加终端

### 3. 图片处理（后期）
**当前**: 忽略图片
**未来**: 集成 CLIP (multimodal) 或 Tesseract (OCR)

---

## 学习资源

### 必看教程
1. [Microsoft MCP for Beginners](https://github.com/microsoft/mcp-for-beginners) - Module 3
2. [MCP Server 示例](https://github.com/alejandro-ao/mcp-server-example) - YouTube 教程
3. [ChromaDB Cookbook](https://cookbook.chromadb.dev)

### Python 基础（如果需要）
- 变量、函数、循环
- 文件读写
- 基础命令行操作

### macOS 自动化
- fswatch 文档
- launchd 教程

---

## 成本预算

| 项目 | 费用 |
|------|------|
| 硬件 | $0 (已有) |
| 软件 | $0 (开源) |
| DeepSeek API | ~$5-10/月 |
| Poke | ~$3-30/月 |
| **年度总成本** | **$96-480** |

---

## 下一步行动

✅ 创建项目目录
⏳ 编写完整的 `server.py`（带详细注释）
⏳ 提供安装脚本
⏳ 创建配置文件模板

---

*本文档持续更新*
