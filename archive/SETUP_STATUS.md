# Apple Notes MCP - 环境搭建状态

**更新时间**: 2025-11-04 00:47

---

## ✅ 已完成的步骤

### 1. Python 环境 ✓
- **Python 版本**: 3.9.6 (系统自带)
- **Pip 版本**: 25.3 (已升级)
- **位置**: `/Applications/Xcode.app/Contents/Developer/usr/bin/python3`

### 2. Python 依赖包 ✓
已成功安装以下包（在 `~/.local` 用户目录）：
- ✅ `apple-notes-to-sqlite` - 备忘录导出工具
- ✅ `chromadb` - 向量数据库
- ✅ `fastembed` - 嵌入模型（ONNX Runtime）
- ✅ 所有相关依赖（numpy, onnxruntime, 等）

**PATH 配置需求**:
```bash
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
```
建议添加到 `~/.zshrc` 或 `~/.bash_profile`

### 3. 备忘录导出 ✓
- **数据库位置**: `~/notes.db`
- **导出笔记数**: 920 条
- **表结构**:
  - `id` (TEXT PRIMARY KEY)
  - `created` (TEXT)
  - `updated` (TEXT)
  - `title` (TEXT)
  - `body` (TEXT - 包含 HTML)

### 4. 向量索引 ✓
- **ChromaDB 位置**: `~/Documents/apple-notes-mcp/chroma_db/`
- **已索引笔记数**: 920 条
- **索引覆盖率**: 100%
- **嵌入模型**: all-MiniLM-L6-v2 (384 维)
- **模型缓存**: `~/.cache/chroma/onnx_models/`

### 5. 脚本文件 ✓
- ✅ `~/Documents/apple-notes-mcp/scripts/indexer.py` - 索引管理脚本

**功能**:
```bash
# 增量索引（默认）
python3 indexer.py

# 全量索引
python3 indexer.py full

# 测试搜索
python3 indexer.py search "关键词"

# 显示统计
python3 indexer.py stats
```

---

## ⚠️ 待完成的步骤

### 1. Python 版本升级 (必需)
**问题**: MCP SDK 需要 Python 3.10+，当前系统是 3.9.6

**解决方案选项**:

#### 选项 A: 使用 Homebrew 安装 Python 3.12 (推荐)
```bash
# 1. 安装 Homebrew (需要管理员密码)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 安装 Python 3.12
brew install python@3.12

# 3. 验证
python3.12 --version

# 4. 重新安装 MCP SDK
python3.12 -m pip install --user mcp fastmcp
```

#### 选项 B: 从 python.org 下载安装包
1. 访问 https://www.python.org/downloads/
2. 下载 Python 3.12 macOS installer
3. 双击 .pkg 文件安装
4. 重新安装依赖

#### 选项 C: 使用 pyenv (高级用户)
```bash
# 需要先安装 Homebrew
brew install pyenv
pyenv install 3.12.0
pyenv global 3.12.0
```

### 2. 安装 fswatch (用于自动监控)
**选项 A**: Homebrew (推荐)
```bash
brew install fswatch
```

**选项 B**: 手动编译
```bash
# 下载源码
curl -L https://github.com/emcrisostomo/fswatch/releases/download/1.17.1/fswatch-1.17.1.tar.gz -o fswatch.tar.gz
tar -xzf fswatch.tar.gz
cd fswatch-1.17.1
./configure
make
sudo make install
```

**临时替代方案**: 手动运行同步脚本，暂不配置自动监控

### 3. 创建 MCP 服务器脚本
等 Python 3.10+ 安装完成后创建

### 4. 配置 Claude Desktop
编辑 `~/Library/Application Support/Claude/claude_desktop_config.json`

---

## 🛠️ 当前可用功能

尽管 MCP 服务器还未完成，以下功能已经可用：

### ✅ 手动导出和索引
```bash
# 导出最新的备忘录
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
apple-notes-to-sqlite ~/notes.db

# 更新索引（仅新增/修改的笔记）
cd ~/Documents/apple-notes-mcp/scripts
python3 indexer.py
```

### ✅ 语义搜索测试
```bash
cd ~/Documents/apple-notes-mcp/scripts

# 搜索相关笔记
python3 indexer.py search "机器学习"
python3 indexer.py search "项目 想法"
python3 indexer.py search "会议记录"
```

### ✅ 查看统计信息
```bash
python3 indexer.py stats
```

---

## 📋 下一步行动清单

请按照以下顺序完成剩余步骤：

### 立即行动（今天）
- [ ] **步骤 1**: 安装 Homebrew
  - 打开终端，运行安装命令
  - 输入管理员密码
  - 等待安装完成（约 5-10 分钟）

- [ ] **步骤 2**: 使用 Homebrew 安装 Python 3.12
  ```bash
  brew install python@3.12
  ```

- [ ] **步骤 3**: 安装 fswatch
  ```bash
  brew install fswatch
  ```

- [ ] **步骤 4**: 安装 MCP SDK
  ```bash
  python3.12 -m pip install --user mcp fastmcp
  ```

### 后续步骤（完成上述后）
- [ ] **步骤 5**: 创建 MCP 服务器脚本 (`server.py`)
- [ ] **步骤 6**: 配置 Claude Desktop
- [ ] **步骤 7**: 测试 MCP 服务器
- [ ] **步骤 8**: 创建自动同步脚本
- [ ] **步骤 9**: 配置 launchd 开机自启

---

## 🔧 故障排查

### 问题：apple-notes-to-sqlite 找不到命令
**解决**:
```bash
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# 或添加到 ~/.zshrc
echo 'export PATH="$HOME/Library/Python/3.9/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 问题：ChromaDB 警告 "NotOpenSSLWarning"
**原因**: LibreSSL vs OpenSSL 版本问题
**影响**: 仅警告，不影响功能
**解决**: 可忽略，或升级到 Python 3.10+ 后会自动解决

### 问题：中文显示乱码
**原因**: 终端编码问题
**影响**: 仅终端显示，存储和搜索不受影响
**解决**: MCP 服务器中会正常显示

---

## 📊 系统资源使用

### 磁盘空间
- SQLite 数据库: ~10-50 MB（取决于笔记内容）
- ChromaDB 向量库: ~100-500 MB
- ONNX 模型缓存: ~80 MB
- **总计**: 约 200-650 MB

### 内存使用
- 索引时: ~500 MB
- 搜索时: ~200 MB
- 空闲时: ~50 MB

### CPU 使用
- 首次索引（920条笔记）: 约 30-60 秒
- 增量索引（< 10条）: < 5 秒
- 单次搜索: < 100 ms

---

## 📞 获取帮助

### 社区资源
- MCP Discord: https://discord.gg/modelcontextprotocol
- ChromaDB 文档: https://docs.trychroma.com
- GitHub Issues: （可在 implementation-plan.md 中查看链接）

### 调试技巧
```bash
# 查看详细错误信息
python3 indexer.py 2>&1 | tee debug.log

# 检查数据库内容
sqlite3 ~/notes.db "SELECT * FROM notes LIMIT 5;"

# 检查 ChromaDB
python3 -c "import chromadb; print(chromadb.__version__)"
```

---

## 🎯 成功标准

完成所有步骤后，你应该能够：

1. ✅ 在终端中搜索备忘录（已完成）
2. ⏳ 在 Claude Desktop 中搜索备忘录
3. ⏳ 备忘录自动同步更新
4. ⏳ 通过 iMessage (Poke) 搜索备忘录

**当前进度**: 步骤 1 完成 ✅

---

*本文档持续更新*
