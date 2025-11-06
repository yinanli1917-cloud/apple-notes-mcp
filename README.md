# Apple Notes MCP 语义搜索系统

> 使用BGE-M3模型实现高质量中文语义搜索，可部署到云端实现远程访问

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/apple-notes-mcp)

## 功能特性

- ✅ **语义搜索**：基于 BGE-M3 模型（1024维向量）
- ✅ **高准确率**：87% 中文语义匹配准确率
- ✅ **多语言支持**：中英文混合 + 100+ 语言
- ✅ **多端接入**：Claude Desktop、Poke AI（iMessage）
- ✅ **本地/云端**：支持本地和 Railway 云端部署
- ✅ **API 保护**：云端部署自动启用 API Key 认证

## 快速部署

### 方式 1: 本地使用（Claude Desktop）

1. 克隆仓库并安装依赖
2. 导出笔记：`python3 scripts/export_notes_fixed.py`
3. 构建索引：`python3 scripts/indexer.py`
4. 配置 Claude Desktop（见下文）

### 方式 2: 云端部署（Poke AI 远程访问）

1. 点击上方 "Deploy on Railway" 按钮
2. 设置环境变量 `API_KEY`
3. 上传你的 `notes.db`
4. 运行 `build_index_cloud.py`

**详细步骤**: 查看 [DEPLOY.md](DEPLOY.md) 或 [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md)

---

## 当前状态（作者实例）

- **920条笔记** 已索引
- **BGE-M3模型**（1024维向量）
- **中文语义准确率**: 87%
- **支持中英混合搜索**

### 如何使用

1. **在Claude Desktop中搜索**：
   ```
   搜索"幽默搞笑" → 返回相关笔记
   搜索"AI人工智能" → 返回AI主题笔记
   ```

2. **刷新索引**（当你添加新笔记时）：
   - 在Claude Desktop中说："刷新备忘录索引"

3. **调整返回数量**：
   - 默认返回5条，可以说："搜索xxx，返回20条结果"

## 系统架构

```
Apple Notes
    ↓
export_notes_fixed.py (UTF-8导出)
    ↓
~/notes.db (SQLite, 920条笔记)
    ↓
indexer.py (BGE-M3, 1024维向量)
    ↓
~/Documents/apple-notes-mcp/chroma_db/ (向量数据库)
    ↓
server.py (MCP服务器, BGE-M3查询)
    ↓
Claude Desktop (MCP客户端)
```

## 文件说明

### 核心文件
- `scripts/server.py` - MCP服务器（Claude Desktop调用）
- `scripts/indexer.py` - 索引脚本（建立向量数据库）
- `scripts/export_notes_fixed.py` - UTF-8导出脚本

### 配置文件
- `~/.zshrc` - Python 3.12环境变量
- `~/Library/Application Support/Claude/claude_desktop_config.json` - MCP配置

### 数据文件
- `~/notes.db` - SQLite数据库（920条笔记）
- `~/Documents/apple-notes-mcp/chroma_db/` - 向量索引

### 文档（可选阅读）
- `PROJECT_LOG.md` - 完整技术日志（决策过程、测试结果、bug修复）
- `ENCODING_FIX.md` - UTF-8编码修复说明

## 常见操作

### 添加新笔记后刷新索引
```bash
cd ~/Documents/apple-notes-mcp/scripts
python3 export_notes_fixed.py  # 导出笔记
python3 indexer.py              # 增量索引
```

### 查看统计信息
```bash
cd ~/Documents/apple-notes-mcp/scripts
python3 indexer.py stats
```

### 测试搜索（不通过MCP）
```bash
cd ~/Documents/apple-notes-mcp/scripts
python3 indexer.py search "搜索关键词"
```

### 完全重建索引
```bash
rm -rf ~/Documents/apple-notes-mcp/chroma_db/
cd ~/Documents/apple-notes-mcp/scripts
python3 indexer.py full
```

## 技术栈

- **嵌入模型**: BAAI/bge-m3 (1024维)
- **向量数据库**: ChromaDB
- **MCP框架**: FastMCP
- **Python版本**: 3.12

## 性能指标

- 索引时间: ~3分钟（920条笔记）
- 搜索准确率: 87%
- 跨语言: ✅ 支持中英文混合
- 语义理解: ✅ 深度语义，非关键词匹配

## 故障排除

### 搜索报错"Collection expecting embedding with dimension of 1024, got 384"
**解决**: 重启Claude Desktop（Cmd+Q退出后重开）

### 搜索结果中文乱码
**原因**: 使用了旧的export脚本
**解决**: 运行`python3 export_notes_fixed.py`重新导出

### MCP工具不可用
**检查**:
1. `~/Library/Application Support/Claude/claude_desktop_config.json`配置是否正确
2. 重启Claude Desktop
3. 查看日志: `~/Library/Logs/Claude/mcp-server-apple-notes.log`

## Poke AI 集成（iMessage 助手）

**✅ 已实现！** 现在可以通过 Poke AI (Interaction Inc.) 在 iMessage 中搜索你的备忘录。

### 快速开始

1. **启动 HTTP MCP 服务器**：
   ```bash
   cd ~/Documents/apple-notes-mcp/scripts
   python3 server_http.py
   ```

2. **在 Poke AI 中配置**：
   - Name: `Apple Notes Search`
   - Server URL: `http://127.0.0.1:8000/sse`
   - API Key: *(留空)*

3. **在 iMessage 中使用**：
   - "搜索幽默搞笑的内容"
   - "找一找关于 AI 的笔记"
   - "查看备忘录统计"

**详细文档**: 查看 [POKE_INTEGRATION.md](POKE_INTEGRATION.md)

### 两个服务器版本

- **server.py** - Claude Desktop 使用（stdio 传输）
- **server_http.py** - Poke AI 使用（HTTP/SSE 传输）

两者可以同时运行，互不干扰。

## 下一步扩展

### 选项A: 提升搜索质量
1. 使用DeepSeek API重排序
2. 混合检索（BM25 + 向量搜索）
3. 查询扩展

### 选项B: 性能优化
1. MPS GPU加速
2. 模型预加载
3. 批量查询

## 版本控制（存档与回滚）

### 快速操作指南

项目已使用Git进行版本控制，你可以随时创建"存档点"和回滚。

#### 创建存档（每次重要修改后）
```bash
cd ~/Documents/apple-notes-mcp

# 1. 查看修改了什么
git status

# 2. 添加所有修改（或指定文件）
git add .

# 3. 创建存档点（commit）
git commit -m "描述你的修改，例如：添加了XXX功能"
```

#### 查看历史存档
```bash
# 查看所有存档点
git log --oneline

# 查看详细历史
git log
```

#### 回滚到某个存档点
```bash
# 方式1: 回滚所有未提交的修改（恢复到上次commit）
git reset --hard HEAD

# 方式2: 回滚到特定存档点
git log --oneline  # 找到commit的ID（例如：cab9d2d）
git reset --hard cab9d2d  # 回滚到那个存档点

# 方式3: 只是查看旧版本（不真的回滚）
git checkout cab9d2d  # 切换到那个版本查看
git checkout main      # 回到最新版本
```

#### 查看某个文件的修改历史
```bash
# 查看文件修改记录
git log -p scripts/server.py

# 对比当前版本和上次commit的差异
git diff scripts/server.py
```

### 推荐的使用流程

**每次重要修改后**：
1. `git status` - 查看改了什么
2. `git add .` - 添加修改
3. `git commit -m "说明修改内容"` - 创建存档点

**出问题时**：
1. `git log --oneline` - 找到"完美状态"的commit ID
2. `git reset --hard <commit-ID>` - 一键回滚

**当前完美状态存档**：
- Commit: `cab9d2d` (初始版本)
- 描述: BGE-M3语义搜索系统，920条笔记，87%准确率
- 如果出问题，运行: `git reset --hard cab9d2d`

## 项目维护指南

### 文档结构
项目现在只保留3个核心文档：
- **README.md** (本文件) - 快速开始和日常使用
- **PROJECT_LOG.md** - 完整技术决策日志（给技术人员）
- **ENCODING_FIX.md** - UTF-8编码修复说明（特定问题参考）

旧文档已归档到 `archive/` 文件夹，不影响日常使用。

### 上下文管理策略
由于 Claude Code 对话窗口的上下文有限，建议：
1. **当前对话**：专注于已完成的部署和维护
2. **新功能开发**（如Poke集成）：建议开启新对话窗口
3. **技术日志**：所有重要决策已记录在 PROJECT_LOG.md 中
4. **会话延续**：新对话可以读取这3个文档快速恢复上下文

### Claude Code 对话窗口命名
在 VSCode 的 Claude Code 扩展中：
- 对话窗口名称由第一条用户消息自动生成
- 目前无法手动重命名对话窗口
- 建议：开启新对话时，第一条消息使用清晰的标题
  - 例如："Poke集成 - Apple Notes MCP语义搜索"
  - 这样窗口名称会自动设置为该标题

## 项目维护者

- **产品经理**: 用户
- **技术实施**: Claude
- **项目目标**: ✅ 达成 - 实现ima级别中文语义搜索

---

**最后更新**: 2025-11-05
**项目状态**: ✅ 生产环境运行中
