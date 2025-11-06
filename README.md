# Apple Notes AI Search

> Use AI to search your Apple Notes with natural language | 用 AI 自然语言搜索你的苹果备忘录

[English](#english) | [中文](#中文)

---

## English

### What is this?

Turn your Apple Notes into a searchable knowledge base powered by AI. Instead of remembering exact titles, just describe what you're looking for.

![Search Demo](images/demo.png)

### Features

- **Semantic Search**: Understands meaning, not just keywords
- **Chinese Optimized**: 87% accuracy on Chinese text
- **Multi-language**: Supports 100+ languages
- **Privacy First**: All data stays local (optional cloud deploy)
- **Claude Desktop Integration**: Works seamlessly with Claude

### Quick Start

**Requirements:**
- macOS
- Python 3.10+
- Basic terminal knowledge (or ask AI like Claude to help!)

**Installation (5 minutes):**

```bash
# Clone the repo
git clone https://github.com/yinanli1917-cloud/apple-notes-mcp.git
cd apple-notes-mcp

# Install dependencies
pip3 install -r requirements.txt

# Export your notes
cd scripts && python3 export_notes_fixed.py

# Build search index (takes 3-5 minutes first time)
python3 indexer.py
```

**Use with Claude Desktop:**

1. Edit Claude's config file:
   ```bash
   open ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

2. Add this configuration (update the path):
   ```json
   {
     "mcpServers": {
       "apple-notes": {
         "command": "python3",
         "args": ["/Users/YOUR_USERNAME/Documents/apple-notes-mcp/scripts/server.py"]
       }
     }
   }
   ```

3. Restart Claude Desktop

4. Try searching: `Search for "funny content" in my notes`

👉 [Learn more about configuring MCP servers](https://modelcontextprotocol.io/quickstart/user)

### Cost

**Local (Free):**
- All data stays on your Mac
- Complete privacy
- No internet required (except downloading models)

**Cloud Deploy (Optional):**
- Fly.io: ~$2-3/month
- Railway: ~$5/month
- Access from anywhere with your phone

### Tech Stack

- **BGE-M3**: Chinese-optimized embedding model (1024-dim)
- **ChromaDB**: Vector database
- **FastMCP**: MCP protocol framework
- **Python 3.12**

### Documentation

- [Cloud Deployment Guide](docs/DEPLOY.md)
- [Poke AI Integration](docs/POKE_INTEGRATION.md) (Work in Progress)
- [Technical Details](docs/PROJECT_LOG.md)

### Contributing

Contributions welcome! Feel free to:
- Report bugs
- Suggest features
- Improve documentation
- Submit pull requests

### License

MIT License © 2025 [Yinan Li](https://github.com/yinanli1917-cloud)

**Made with ❤️ by [Yinan Li](https://github.com/yinanli1917-cloud) & [Claude Code](https://claude.ai/claude-code)**

---

## 中文

### 这是什么？

用 AI 把你的苹果备忘录变成可搜索的知识库。不需要记住笔记标题，只要描述你想找什么就行。

![搜索演示](images/demo.png)

### 特性

- **语义搜索**：理解含义，而不仅仅是关键词匹配
- **中文优化**：针对中文优化，准确率 87%
- **多语言支持**：支持 100+ 种语言
- **隐私优先**：数据保存在本地（可选云端部署）
- **Claude Desktop 集成**：与 Claude 无缝配合

### 快速开始

**前置要求：**
- macOS 电脑
- Python 3.10+
- 基础的终端使用（或者让 AI 比如 Claude 帮你！）

**安装步骤（5 分钟）：**

```bash
# 克隆项目
git clone https://github.com/yinanli1917-cloud/apple-notes-mcp.git
cd apple-notes-mcp

# 安装依赖
pip3 install -r requirements.txt

# 导出备忘录
cd scripts && python3 export_notes_fixed.py

# 建立搜索索引（首次需要 3-5 分钟）
python3 indexer.py
```

**在 Claude Desktop 中使用：**

1. 编辑 Claude 配置文件：
   ```bash
   open ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

2. 添加以下配置（修改路径为你的实际路径）：
   ```json
   {
     "mcpServers": {
       "apple-notes": {
         "command": "python3",
         "args": ["/Users/你的用户名/Documents/apple-notes-mcp/scripts/server.py"]
       }
     }
   }
   ```

3. 重启 Claude Desktop

4. 试试搜索：`搜索我笔记里的"幽默搞笑"内容`

👉 [了解更多关于配置 MCP 服务器](https://modelcontextprotocol.io/quickstart/user)

### 费用

**本地使用（免费）：**
- 所有数据保存在你的 Mac 上
- 完全隐私保护
- 无需联网（除了下载模型）

**云端部署（可选）：**
- Fly.io：约 $2-3/月
- Railway：约 $5/月
- 可以在任何地方用手机访问

### 技术栈

- **BGE-M3**：中文优化的嵌入模型（1024 维向量）
- **ChromaDB**：向量数据库
- **FastMCP**：MCP 协议框架
- **Python 3.12**

### 文档

- [云端部署指南](docs/DEPLOY.md)
- [Poke AI 集成](docs/POKE_INTEGRATION.md)（开发中）
- [技术文档](docs/PROJECT_LOG.md)

### 参与贡献

欢迎贡献！你可以：
- 报告 Bug
- 提出功能建议
- 改进文档
- 提交 Pull Request

### 常见问题

**Q: 我不会用命令行怎么办？**

A: 可以让 AI 助手（比如 Claude、ChatGPT）帮你！复制命令给它们，让它们一步步指导你。

**Q: 支持其他笔记应用吗？**

A: 目前只支持 Apple Notes。Notion、Evernote 等可以先导出成文本后使用。

**Q: 能在手机上用吗？**

A: 需要部署到云端（Fly.io 或 Railway），费用约 $2-5/月。

### 致谢

**灵感来源**：[ima (腾讯出品)](https://ima.qq.com/download?webFrom=10000075) - 优秀的 Apple Notes 搜索应用

**使用的开源项目**：
- [FastMCP](https://github.com/jlowin/fastmcp)
- [BGE-M3](https://github.com/FlagOpen/FlagEmbedding)
- [ChromaDB](https://www.trychroma.com/)

### 开源协议

MIT License © 2025 [Yinan Li](https://github.com/yinanli1917-cloud)

**Made with ❤️ by [Yinan Li](https://github.com/yinanli1917-cloud) & [Claude Code](https://claude.ai/claude-code)**

如果觉得有用，请给我们一个 ⭐！
