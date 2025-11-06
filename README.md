<div align="center">

# 🔍 Apple Notes AI Search

**让 AI 帮你搜索 Apple 备忘录**

<p align="center">
  <img src="https://img.shields.io/github/stars/yinanli1917-cloud/apple-notes-mcp?style=for-the-badge&color=yellow" alt="Stars">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Made%20with-❤️-red.svg?style=for-the-badge" alt="Made with Love">
</p>

<p align="center">
  <strong>不用记住笔记标题，描述你想找什么就行</strong>
</p>

<p align="center">
  <a href="#-快速开始">快速开始</a> •
  <a href="#-演示">演示</a> •
  <a href="#-文档">文档</a> •
  <a href="https://github.com/yinanli1917-cloud/apple-notes-mcp/issues">报告问题</a>
</p>

---

### 💬 搜索示例

```
你：帮我找幽默搞笑的内容
AI：找到 5 个相关笔记：😄 笑话、搞笑段子、讽刺文章...

你：上个月关于 AI 的想法
AI：找到 8 个笔记：🤖 ChatGPT 使用心得、机器学习笔记...

你：美国政治制度
AI：找到 6 个笔记：🏛️ 代议制批判、三权分立、政治哲学...
```

</div>

---

## ✨ 特性

<table>
<tr>
<td width="33%" align="center">

### 🧠 语义理解

不是简单的关键词匹配
真正理解你的意思

搜"幽默"也能找到"笑话"

</td>
<td width="33%" align="center">

### 🌏 中英混合

专门优化中文搜索
同时支持 100+ 语言

搜索准确率：**87%**

</td>
<td width="33%" align="center">

### 🔌 多端集成

Claude Desktop ✅
Poke AI (测试中) 🚧
任何 MCP 客户端

</td>
</tr>
</table>

---

## 🚀 快速开始

### 前置要求

- macOS 电脑
- Python 3.10+
- 会用终端运行命令

### 安装步骤（5 分钟）

```bash
# 1. 克隆项目
git clone https://github.com/yinanli1917-cloud/apple-notes-mcp.git
cd apple-notes-mcp

# 2. 安装依赖
pip3 install -r requirements.txt

# 3. 导出备忘录
cd scripts && python3 export_notes_fixed.py

# 4. 建立索引（首次需要 3-5 分钟）
python3 indexer.py
```

### 在 Claude Desktop 中使用

1. 编辑配置文件：
   ```bash
   open ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

2. 添加配置（修改路径为你的实际路径）：
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

3. 重启 Claude Desktop，开始搜索！

> 💡 **提示**：在 Claude 对话中输入 `搜索"幽默搞笑的内容"` 试试

---

## 📊 演示

### 搜索效果

| 你的问题 | AI 找到的笔记 | 准确率 |
|---------|-------------|-------|
| "幽默搞笑的内容" | 😄 笑话、搞笑段子、讽刺幽默 | ⭐⭐⭐⭐⭐ |
| "关于 AI 的想法" | 🤖 ChatGPT、机器学习、AI 应用 | ⭐⭐⭐⭐⭐ |
| "美国政治制度" | 🏛️ 代议制、三权分立、政治哲学 | ⭐⭐⭐⭐⭐ |

**基于 920 条笔记的实测数据**

---

## 💰 费用

### 本地使用（推荐）

<table>
<tr>
<td width="50%">

**完全免费** 💚

- ✅ 所有数据在本地
- ✅ 隐私完全保护
- ✅ 无需联网使用

</td>
<td width="50%">

**限制**

- ⚠️ 只能在 Mac 上用
- ⚠️ 需要一点命令行基础

</td>
</tr>
</table>

### 云端部署（可选）

想在手机上用？可以部署到云端：

- **Fly.io**：~$2-3/月
- **Railway**：~$5/月

> ⚠️ 云端部署会上传笔记数据（但只有你能访问）

---

## 🔐 隐私安全

- ✅ 笔记数据库不会上传到 GitHub
- ✅ 本地部署数据完全在你的设备上
- ✅ 云端部署有 API Key 保护
- ✅ 代码开源，可以自己审查

**包含敏感信息的笔记？** → 建议只用本地部署

---

## 🛠️ 工作原理

```
Apple Notes → 导出 → AI 理解（BGE-M3）→ 向量存储（ChromaDB）→ 搜索
```

**技术栈**：
- BGE-M3: 中文语义嵌入模型（1024 维）
- ChromaDB: 向量数据库
- FastMCP: MCP 协议框架
- Python 3.12

---

## 📚 文档

<table>
<tr>
<td align="center" width="33%">

### 📖 部署指南

[云端部署](DEPLOY.md)

Fly.io / Railway 部署教程

</td>
<td align="center" width="33%">

### 📱 Poke AI 集成

[Poke 集成](POKE_INTEGRATION.md)

通过 iMessage 搜索（测试中）

</td>
<td align="center" width="33%">

### 🔧 开发文档

[技术文档](PROJECT_LOG.md)

技术细节和决策记录

</td>
</tr>
</table>

---

## 🎯 适合你吗？

### ✅ 推荐使用，如果你：

- 用 Apple Notes 并且笔记很多（50+ 条）
- 经常找不到笔记在哪
- 想让 AI 帮你整理和搜索
- 不介意用一点命令行

### ⚠️ 可能不适合，如果你：

- 不用 Apple Notes（目前只支持）
- 笔记很少（几条笔记不需要 AI）
- 完全不会用命令行

---

## 🙋 常见问题

<details>
<summary><b>Q: 支持其他笔记应用吗？</b></summary>

A: 目前只支持 Apple Notes。Notion、Evernote 等可以先导出成文本，稍作修改就能用。欢迎贡献代码支持更多应用！

</details>

<details>
<summary><b>Q: 我不会用命令行怎么办？</b></summary>

A: 目前需要一点命令行基础。可以找技术朋友帮忙，或等我们做图形界面版本。

</details>

<details>
<summary><b>Q: 搜索结果不准确怎么办？</b></summary>

A: 试试换个说法，或增加返回结果数量（"搜索 XXX，返回 20 条"）。

</details>

<details>
<summary><b>Q: 能自动同步吗？</b></summary>

A: 目前需要手动运行命令更新。自动同步功能正在开发中！

</details>

---

## 🤝 贡献

欢迎任何形式的贡献！

- 🐛 [报告 Bug](https://github.com/yinanli1917-cloud/apple-notes-mcp/issues)
- 💡 [提出建议](https://github.com/yinanli1917-cloud/apple-notes-mcp/issues/new)
- 📝 改进文档
- 💻 提交代码

### 开发计划

- [ ] 图形界面（不需要命令行）
- [ ] 支持更多笔记应用
- [ ] 自动同步功能
- [ ] 更多 AI 客户端支持

---

## 🙏 致谢

**灵感来源**：[ima](https://ima.app) - 优秀的 Apple Notes 搜索应用

**使用的开源项目**：
- [FastMCP](https://github.com/jlowin/fastmcp) - MCP 框架
- [BGE-M3](https://github.com/FlagOpen/FlagEmbedding) - 嵌入模型
- [ChromaDB](https://www.trychroma.com/) - 向量数据库

---

## 📄 开源协议

MIT License © 2025 [Yinan Li](https://github.com/yinanli1917-cloud)

---

<div align="center">

**Made with ❤️ by [Yinan Li](https://github.com/yinanli1917-cloud) & [Claude Code](https://claude.ai/claude-code)**

如果觉得有用，请给我们一个 ⭐！

<a href="https://github.com/yinanli1917-cloud/apple-notes-mcp">
  <img src="https://img.shields.io/github/stars/yinanli1917-cloud/apple-notes-mcp?style=social" alt="Star on GitHub">
</a>

</div>
