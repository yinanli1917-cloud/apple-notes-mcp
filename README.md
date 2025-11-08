# Apple Notes AI Search

> Use AI to search and index your Apple Notes with natural language | 用 AI 自然语言检索你的苹果备忘录

[English](#english) | [中文](#中文)

---

## English

### What is this?

Turn your Apple Notes into a searchable knowledge base powered by AI. Instead of remembering exact titles, just describe what you're looking for.

![Search Demo in Claude Desktop.png](https://github.com/yinanli1917-cloud/apple-notes-mcp/blob/7dcb7766ec1c2d099339fc4c0818665d555a263b/images/Search%20Demo%20in%20Claude%20Desktop.png)

### Features

- **Semantic Search**: Understands meaning, not just keywords
- **Chinese Optimized**: 87% accuracy on Chinese text
- **Multi-language**: Supports 100+ languages
- **Privacy First**: All data stays local (optional cloud deploy)
- **Claude Desktop Integration**: Works seamlessly with Claude
- **Poke AI Integration**: Search your notes via iMessage (NEW!)

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

**Use with Poke AI (iMessage):**

Search your notes directly from iMessage using Poke AI!

1. Install [Poke AI](https://poke.com) on your iPhone
2. Start the services on your Mac:
   ```bash
   cd ~/Documents/apple-notes-mcp/scripts
   ./start_poke_services.sh
   ```
3. Configure Poke AI with the MCP server URL:
   ```
   https://apple-notes-mcp.yinanli1917.workers.dev/sse
   ```
4. Search via iMessage: "Search my notes for funny jokes"

👉 [Full Poke AI Setup Guide](docs/POKE_INTEGRATION.md)

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

**Core Search:**
- **BGE-M3**: Chinese-optimized embedding model (1024-dim)
- **ChromaDB**: Vector database
- **Python 3.12**

**Integrations:**
- **FastMCP**: MCP protocol framework (Claude Desktop)
- **Cloudflare Workers**: Serverless platform (Poke AI)
- **Cloudflare Tunnel**: Secure local-to-cloud bridge

### Documentation

- [Poke AI Integration Guide](docs/POKE_INTEGRATION.md) - Search via iMessage
- [Cloudflare Tunnel Setup](docs/CLOUDFLARE_TUNNEL.md) - Local-to-cloud bridge
- [Cloud Deployment Guide](docs/DEPLOY.md) - Deploy to Fly.io/Railway
- [Project Status](STATUS.md) - Current features and roadmap
- [Technical Details](docs/PROJECT_LOG.md) - Development log

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

![在 Claude Desktop 里的搜索演示](https://github.com/yinanli1917-cloud/apple-notes-mcp/blob/7dcb7766ec1c2d099339fc4c0818665d555a263b/images/Search%20Demo%20in%20Claude%20Desktop.png)

### 特性

- **语义搜索**：理解含义，而不仅仅是关键词匹配
- **中文优化**：针对中文优化，准确率 87%
- **多语言支持**：支持 100+ 种语言
- **隐私优先**：数据保存在本地（可选云端部署）
- **Claude Desktop 集成**：与 Claude 无缝配合
- **Poke AI 集成**：通过 iMessage 搜索笔记（新功能！）

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

**在 Poke AI（iMessage）中使用：**

直接通过 iMessage 搜索你的备忘录！

1. 在 iPhone 上安装 [Poke AI](https://poke.com)
2. 在 Mac 上启动服务：
   ```bash
   cd ~/Documents/apple-notes-mcp/scripts
   ./start_poke_services.sh
   ```
3. 在 Poke AI 中配置 MCP 服务器 URL：
   ```
   https://apple-notes-mcp.yinanli1917.workers.dev/sse
   ```
4. 通过 iMessage 搜索："搜索我的笔记里关于幽默搞笑的内容"

👉 [完整 Poke AI 配置指南](docs/POKE_INTEGRATION.md)

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

**核心搜索：**
- **BGE-M3**：中文优化的嵌入模型（1024 维向量）
- **ChromaDB**：向量数据库
- **Python 3.12**

**集成方式：**
- **FastMCP**：MCP 协议框架（Claude Desktop）
- **Cloudflare Workers**：无服务器平台（Poke AI）
- **Cloudflare Tunnel**：安全的本地到云端桥接

### 文档

- [Poke AI 集成指南](docs/POKE_INTEGRATION.md) - 通过 iMessage 搜索
- [Cloudflare Tunnel 配置](docs/CLOUDFLARE_TUNNEL.md) - 本地到云端桥接
- [云端部署指南](docs/DEPLOY.md) - 部署到 Fly.io/Railway
- [项目状态](STATUS.md) - 当前功能和路线图
- [技术文档](docs/PROJECT_LOG.md) - 开发日志

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

**灵感来源**：[ima (腾讯出品)](https://ima.qq.com/download?webFrom=10000075) - 优秀的 在线RAG个人知识库 应用

**使用的开源项目**：
- [FastMCP](https://github.com/jlowin/fastmcp)
- [BGE-M3](https://github.com/FlagOpen/FlagEmbedding)
- [ChromaDB](https://www.trychroma.com/)

### 开源协议

MIT License © 2025 [Yinan Li](https://github.com/yinanli1917-cloud)

**Made with ❤️ by [Yinan Li](https://github.com/yinanli1917-cloud) & [Claude Code](https://claude.ai/claude-code)**

如果觉得有用，请给我们一个 ⭐！
