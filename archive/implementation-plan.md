# 苹果备忘录智能搜索 MCP - 完整实施方案

**版本**: 1.0
**创建时间**: 2025-11-04
**目标用户**: 零编程基础
**预计时间**: 5周（每周5-7小时）

---

## 📋 目录

1. [项目概述](#项目概述)
2. [技术架构](#技术架构)
3. [分阶段实施计划](#分阶段实施计划)
4. [详细技术文档](#详细技术文档)
5. [常见问题解决](#常见问题解决)
6. [学习资源](#学习资源)
7. [成本预算](#成本预算)

---

## 项目概述

### 🎯 核心目标

创建一个智能备忘录搜索系统，实现：

1. **自动导出**：定期导出苹果备忘录到本地数据库
2. **语义搜索**：不需要精确关键词，理解意图进行模糊搜索
3. **多步推理**：AI 可以先搜索→分析→再次搜索，逐步定位内容
4. **iMessage 集成**：通过 Poke 在 iMessage 中直接搜索备忘录
5. **智能定位**：精准告诉你哪一篇备忘录的哪些内容相关

### ✅ 与现有方案的对比

| 功能 | 当前方案 | 本项目方案 |
|------|----------|------------|
| 搜索方式 | 随机选50篇再搜索 | 智能语义搜索全部笔记 |
| 搜索精度 | 低（可能遗漏） | 高（向量相似度匹配） |
| 多轮搜索 | 不支持 | 支持（AI 逐步细化） |
| 访问方式 | 仅 Claude Desktop | iMessage + Claude Desktop |
| 自动化 | 手动导出 | 自动监控同步 |

---

## 技术架构

### 🏗️ 系统组件

```
┌─────────────────────────────────────────────────────┐
│                  Apple Notes App                    │
│         ~/Library/Group Containers/                 │
│         group.com.apple.notes/NoteStore.sqlite      │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ ① fswatch 监控文件变化
                   │    (60秒防抖)
                   ▼
┌─────────────────────────────────────────────────────┐
│            导出层：apple-notes-to-sqlite            │
│                                                     │
│  ✓ 使用 AppleScript 读取备忘录                      │
│  ✓ 导出到 SQLite: ~/notes.db                       │
│  ✓ 表结构: folders + notes (id, title, body)       │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ ② Python 脚本读取并处理
                   ▼
┌─────────────────────────────────────────────────────┐
│              索引层：ChromaDB + FastEmbed           │
│                                                     │
│  ✓ 向量数据库: ~/notes_chroma/                     │
│  ✓ 嵌入模型: BGE-small-en-v1.5 (384维)             │
│  ✓ 增量更新: 仅索引新增/修改的笔记                  │
│  ✓ 元数据: 标题、日期、文件夹、标签                 │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ ③ MCP Protocol 暴露工具
                   ▼
┌─────────────────────────────────────────────────────┐
│               MCP 服务器：FastMCP                   │
│                                                     │
│  工具列表:                                          │
│  • search_notes(query, limit)                      │
│    → 语义搜索备忘录                                 │
│  • refine_search(query, date_range, folder)        │
│    → 精细化搜索（带过滤条件）                        │
│  • refresh_index()                                 │
│    → 手动触发重新索引                               │
│                                                     │
│  传输模式:                                          │
│  • stdio (Claude Desktop 本地)                     │
│  • SSE over HTTPS (Poke 远程)                      │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ ④ MCP 客户端调用
                   ▼
┌─────────────────────────────────────────────────────┐
│                  客户端层                           │
│                                                     │
│  方式A: Claude Desktop (本地测试)                   │
│  方式B: Poke AI (iMessage 交互)                     │
│  方式C: Cursor / 其他 MCP 客户端                    │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ ⑤ Function Calling
                   ▼
┌─────────────────────────────────────────────────────┐
│              LLM 层：DeepSeek V3                    │
│                                                     │
│  • 接收工具定义                                     │
│  • 决定调用哪个工具                                 │
│  • 分析返回结果                                     │
│  • 多轮调用（思考→搜索→再搜索）                      │
│  • 综合最终答案                                     │
└─────────────────────────────────────────────────────┘
```

### 🔧 核心技术栈

| 层级 | 技术选型 | 理由 |
|------|----------|------|
| **导出** | apple-notes-to-sqlite | 命令行工具，易于自动化 |
| **存储** | SQLite | 轻量级，无需额外数据库服务 |
| **向量库** | ChromaDB | 纯 Python，1000条笔记性能足够 |
| **嵌入** | FastEmbed + BGE | 无需 PyTorch，CPU 优化 |
| **MCP框架** | FastMCP | 初学者友好，装饰器语法 |
| **LLM** | DeepSeek V3 | 便宜，支持 function calling |
| **自动化** | fswatch + launchd | macOS 原生，稳定可靠 |
| **通信** | Poke | 已支持 MCP，直接接入 |

---

## 分阶段实施计划

### 📅 第1周：环境搭建与手动导出

**目标**: 完成开发环境配置，实现手动导出功能

#### 步骤 1.1：安装 Homebrew（如果没有）

```bash
# 打开终端（Terminal.app），粘贴以下命令
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装完成后，验证
brew --version
```

#### 步骤 1.2：安装 Python 工具

```bash
# 安装 Python 包管理器（如果没有 pip）
python3 -m ensurepip --upgrade

# 安装核心依赖
pip3 install apple-notes-to-sqlite
pip3 install chromadb
pip3 install fastembed
pip3 install mcp

# 安装文件监控工具
brew install fswatch
```

#### 步骤 1.3：测试手动导出

```bash
# 导出备忘录到 SQLite 数据库
apple-notes-to-sqlite ~/notes.db

# 检查导出结果
sqlite3 ~/notes.db "SELECT COUNT(*) FROM notes;"
sqlite3 ~/notes.db "SELECT title FROM notes LIMIT 5;"
```

**可能的问题**：
- ❌ **"操作不被允许"**: 需要授予终端完全磁盘访问权限
  - 系统设置 → 隐私与安全 → 完全磁盘访问 → 添加 Terminal

#### 步骤 1.4：创建项目目录

```bash
# 创建项目结构
mkdir -p ~/Documents/apple-notes-mcp/{scripts,logs,config}

# 目录说明：
# - scripts/  存放 Python 脚本
# - logs/     存放运行日志
# - config/   存放配置文件
```

**第1周交付物**：
- ✅ 所有工具安装完成
- ✅ 能够手动导出备忘录到 ~/notes.db
- ✅ 项目目录结构创建完成

**预计时间**: 4-6小时

---

### 📅 第2周：向量搜索系统

**目标**: 搭建本地语义搜索引擎

#### 步骤 2.1：创建索引脚本

创建文件 `~/Documents/apple-notes-mcp/scripts/indexer.py`:

```python
#!/usr/bin/env python3
"""
备忘录索引脚本
功能：读取 SQLite 中的备忘录，生成向量并存入 ChromaDB
"""

import sqlite3
import chromadb
import os
from datetime import datetime

# ============ 配置 ============
NOTES_DB = os.path.expanduser("~/notes.db")
CHROMA_DB = os.path.expanduser("~/Documents/apple-notes-mcp/chroma_db")
LAST_SYNC_FILE = os.path.expanduser("~/Documents/apple-notes-mcp/.last_sync")

# ============ 初始化 ChromaDB ============
client = chromadb.PersistentClient(path=CHROMA_DB)
collection = client.get_or_create_collection(
    name="apple_notes",
    metadata={"description": "Apple Notes 语义搜索"}
)

# ============ 读取上次同步时间 ============
def get_last_sync_time():
    """读取上次同步时间，如果不存在返回 1970-01-01"""
    try:
        with open(LAST_SYNC_FILE, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        return "1970-01-01 00:00:00"

# ============ 保存同步时间 ============
def save_sync_time():
    """保存当前时间为最后同步时间"""
    with open(LAST_SYNC_FILE, 'w') as f:
        f.write(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

# ============ 增量索引 ============
def incremental_index():
    """仅索引新增或修改的备忘录"""
    last_sync = get_last_sync_time()
    print(f"上次同步时间: {last_sync}")

    # 连接 SQLite
    conn = sqlite3.connect(NOTES_DB)
    cursor = conn.execute("""
        SELECT id, title, body, created, updated
        FROM notes
        WHERE updated > ?
        ORDER BY updated DESC
    """, (last_sync,))

    # 获取变更的笔记
    changed_notes = cursor.fetchall()
    print(f"发现 {len(changed_notes)} 条新增或修改的笔记")

    if not changed_notes:
        print("无需更新")
        conn.close()
        return

    # 批量更新到 ChromaDB
    for note_id, title, body, created, updated in changed_notes:
        # 合并标题和正文
        content = f"{title}\n\n{body}" if title else body

        # 准备元数据
        metadata = {
            "title": title or "(无标题)",
            "created": created,
            "updated": updated
        }

        # Upsert（更新或插入）
        collection.upsert(
            ids=[note_id],
            documents=[content],
            metadatas=[metadata]
        )

        print(f"✓ 索引: {title[:50]}...")

    conn.close()
    save_sync_time()
    print(f"✅ 索引完成！共处理 {len(changed_notes)} 条笔记")

# ============ 全量索引（首次使用） ============
def full_index():
    """索引所有备忘录（首次运行）"""
    print("执行全量索引...")

    conn = sqlite3.connect(NOTES_DB)
    cursor = conn.execute("SELECT id, title, body, created, updated FROM notes")

    all_notes = cursor.fetchall()
    print(f"总共 {len(all_notes)} 条笔记")

    batch_size = 100
    for i in range(0, len(all_notes), batch_size):
        batch = all_notes[i:i+batch_size]

        ids = []
        documents = []
        metadatas = []

        for note_id, title, body, created, updated in batch:
            ids.append(note_id)
            documents.append(f"{title}\n\n{body}" if title else body)
            metadatas.append({
                "title": title or "(无标题)",
                "created": created,
                "updated": updated
            })

        collection.upsert(ids=ids, documents=documents, metadatas=metadatas)
        print(f"进度: {min(i+batch_size, len(all_notes))}/{len(all_notes)}")

    conn.close()
    save_sync_time()
    print("✅ 全量索引完成！")

# ============ 测试搜索 ============
def test_search(query, limit=5):
    """测试搜索功能"""
    print(f"\n🔍 搜索: {query}")
    results = collection.query(
        query_texts=[query],
        n_results=limit
    )

    print(f"找到 {len(results['documents'][0])} 个结果:\n")
    for i, (doc, metadata) in enumerate(zip(results['documents'][0], results['metadatas'][0])):
        print(f"--- 结果 {i+1} ---")
        print(f"标题: {metadata['title']}")
        print(f"内容: {doc[:200]}...")
        print(f"更新时间: {metadata['updated']}\n")

# ============ 主函数 ============
if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "full":
            full_index()
        elif command == "search":
            query = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else "机器学习"
            test_search(query)
        else:
            print("用法: python indexer.py [full|search <关键词>]")
    else:
        # 默认执行增量索引
        incremental_index()
```

#### 步骤 2.2：首次全量索引

```bash
# 赋予执行权限
chmod +x ~/Documents/apple-notes-mcp/scripts/indexer.py

# 首次运行：全量索引
python3 ~/Documents/apple-notes-mcp/scripts/indexer.py full

# 预期输出：
# 执行全量索引...
# 总共 XXX 条笔记
# 进度: 100/XXX
# ✅ 全量索引完成！
```

#### 步骤 2.3：测试搜索

```bash
# 测试语义搜索
python3 ~/Documents/apple-notes-mcp/scripts/indexer.py search "机器学习项目"

# 应该看到相关笔记的前200个字符
```

#### 步骤 2.4：测试增量更新

```bash
# 修改一条备忘录（在 Apple Notes 中）
# 然后运行增量索引
python3 ~/Documents/apple-notes-mcp/scripts/indexer.py

# 预期输出：
# 上次同步时间: 2025-11-04 10:30:00
# 发现 1 条新增或修改的笔记
# ✓ 索引: XXX...
# ✅ 索引完成！共处理 1 条笔记
```

**第2周交付物**：
- ✅ 所有笔记已索引到 ChromaDB
- ✅ 搜索功能正常工作
- ✅ 增量更新机制运行正常

**预计时间**: 6-8小时

---

### 📅 第3周：MCP 服务器开发

**目标**: 创建完整的 MCP 服务器，支持 Claude Desktop

#### 步骤 3.1：安装 MCP SDK

```bash
# 安装 FastMCP（简化版 MCP SDK）
pip3 install fastmcp

# 或使用官方 SDK
pip3 install mcp
```

#### 步骤 3.2：创建 MCP 服务器

创建文件 `~/Documents/apple-notes-mcp/scripts/server.py`:

```python
#!/usr/bin/env python3
"""
Apple Notes MCP 服务器
提供语义搜索和索引管理工具
"""

from mcp.server.fastmcp import FastMCP
import chromadb
import sqlite3
import os
import subprocess
from datetime import datetime

# ============ 配置 ============
NOTES_DB = os.path.expanduser("~/notes.db")
CHROMA_DB = os.path.expanduser("~/Documents/apple-notes-mcp/chroma_db")

# ============ 初始化 MCP 和 ChromaDB ============
mcp = FastMCP(name="apple-notes-search")
chroma_client = chromadb.PersistentClient(path=CHROMA_DB)
collection = chroma_client.get_or_create_collection("apple_notes")

# ============ 工具 1: 搜索备忘录 ============
@mcp.tool(description="在 Apple Notes 中进行语义搜索，找到与查询最相关的备忘录")
async def search_notes(query: str, limit: int = 5) -> str:
    """
    语义搜索备忘录

    参数:
        query: 搜索关键词或问题（支持模糊匹配）
        limit: 返回结果数量（默认5条）

    返回:
        匹配的备忘录列表（包含标题、内容摘要、时间）
    """
    try:
        results = collection.query(
            query_texts=[query],
            n_results=limit
        )

        if not results['documents'][0]:
            return "❌ 没有找到相关备忘录"

        # 格式化输出
        output = [f"🔍 搜索: {query}\n找到 {len(results['documents'][0])} 个结果:\n"]

        for i, (doc, metadata) in enumerate(zip(results['documents'][0], results['metadatas'][0])):
            output.append(f"### 结果 {i+1}: {metadata['title']}")
            output.append(f"**更新时间**: {metadata['updated']}")
            output.append(f"**内容**:\n{doc[:300]}...")
            output.append("")  # 空行

        return "\n".join(output)

    except Exception as e:
        return f"❌ 搜索失败: {str(e)}"

# ============ 工具 2: 精细化搜索 ============
@mcp.tool(description="使用过滤条件进行更精确的搜索（支持日期范围、关键词组合）")
async def refine_search(
    query: str,
    date_after: str = None,
    date_before: str = None,
    limit: int = 5
) -> str:
    """
    精细化搜索

    参数:
        query: 搜索查询
        date_after: 只搜索此日期之后的笔记（格式：YYYY-MM-DD）
        date_before: 只搜索此日期之前的笔记（格式：YYYY-MM-DD）
        limit: 返回结果数量
    """
    try:
        # 构建过滤条件
        where = {}
        if date_after:
            where["updated"] = {"$gte": date_after}
        if date_before:
            if "updated" in where:
                where["updated"]["$lte"] = date_before
            else:
                where["updated"] = {"$lte": date_before}

        # 执行搜索
        results = collection.query(
            query_texts=[query],
            n_results=limit,
            where=where if where else None
        )

        if not results['documents'][0]:
            return "❌ 没有找到符合条件的备忘录"

        # 格式化输出
        output = [f"🔍 精细搜索: {query}"]
        if date_after or date_before:
            output.append(f"📅 时间范围: {date_after or '不限'} ~ {date_before or '不限'}")
        output.append(f"找到 {len(results['documents'][0])} 个结果:\n")

        for i, (doc, metadata) in enumerate(zip(results['documents'][0], results['metadatas'][0])):
            output.append(f"### 结果 {i+1}: {metadata['title']}")
            output.append(f"**更新时间**: {metadata['updated']}")
            output.append(f"**内容**:\n{doc[:300]}...")
            output.append("")

        return "\n".join(output)

    except Exception as e:
        return f"❌ 搜索失败: {str(e)}"

# ============ 工具 3: 刷新索引 ============
@mcp.tool(description="手动触发备忘录导出和重新索引")
async def refresh_index() -> str:
    """
    刷新索引

    功能：
    1. 重新导出 Apple Notes 到 SQLite
    2. 增量更新向量数据库
    """
    try:
        # 1. 导出备忘录
        subprocess.run(
            ["apple-notes-to-sqlite", NOTES_DB],
            check=True,
            capture_output=True
        )

        # 2. 运行索引脚本
        indexer_path = os.path.expanduser("~/Documents/apple-notes-mcp/scripts/indexer.py")
        result = subprocess.run(
            ["python3", indexer_path],
            capture_output=True,
            text=True
        )

        return f"✅ 索引刷新完成\n\n{result.stdout}"

    except Exception as e:
        return f"❌ 刷新失败: {str(e)}"

# ============ 工具 4: 获取统计信息 ============
@mcp.tool(description="查看备忘录数量和索引状态")
async def get_stats() -> str:
    """获取统计信息"""
    try:
        # 从 SQLite 获取总数
        conn = sqlite3.connect(NOTES_DB)
        cursor = conn.execute("SELECT COUNT(*) FROM notes")
        total_notes = cursor.fetchone()[0]
        conn.close()

        # 从 ChromaDB 获取索引数
        indexed_count = collection.count()

        return f"""
📊 **备忘录统计**

- 总笔记数: {total_notes}
- 已索引数: {indexed_count}
- 索引覆盖率: {indexed_count/total_notes*100:.1f}%
- 数据库路径: {NOTES_DB}
- 向量库路径: {CHROMA_DB}
        """.strip()

    except Exception as e:
        return f"❌ 获取统计失败: {str(e)}"

# ============ 启动服务器 ============
if __name__ == "__main__":
    print("🚀 启动 Apple Notes MCP 服务器...")
    print(f"📂 备忘录数据库: {NOTES_DB}")
    print(f"🗂️  向量数据库: {CHROMA_DB}")
    print("✅ 服务器运行中，等待 MCP 客户端连接...\n")

    # 使用 stdio 传输（适用于 Claude Desktop）
    mcp.run(transport="stdio")
```

#### 步骤 3.3：配置 Claude Desktop

编辑文件 `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "apple-notes": {
      "command": "python3",
      "args": [
        "/Users/你的用户名/Documents/apple-notes-mcp/scripts/server.py"
      ]
    }
  }
}
```

**重要**: 将 `你的用户名` 替换为你的实际用户名（运行 `whoami` 查看）

#### 步骤 3.4：测试 MCP 服务器

```bash
# 1. 完全退出 Claude Desktop（Cmd+Q）

# 2. 重新打开 Claude Desktop

# 3. 在 Claude 中测试：
# "搜索我的备忘录中关于机器学习的内容"
# "查看备忘录统计信息"
# "刷新备忘录索引"
```

**如何验证成功**：
- Claude 界面底部应显示"使用了 apple-notes 的 search_notes 工具"
- 返回结果应包含你的实际备忘录内容

**调试方法**：
```bash
# 查看 Claude 日志
tail -f ~/Library/Logs/Claude/mcp*.log

# 手动测试 MCP 服务器
python3 ~/Documents/apple-notes-mcp/scripts/server.py
# 应该看到 "✅ 服务器运行中" 消息
```

**第3周交付物**：
- ✅ MCP 服务器运行正常
- ✅ Claude Desktop 可以调用搜索工具
- ✅ 4个工具全部可用（search/refine/refresh/stats）

**预计时间**: 8-12小时

---

### 📅 第4周：自动化与监控

**目标**: 实现全自动同步，无需手动操作

#### 步骤 4.1：创建同步脚本

创建文件 `~/Documents/apple-notes-mcp/scripts/sync.sh`:

```bash
#!/bin/bash

# ==========================
# Apple Notes 自动同步脚本
# ==========================

LOG_FILE="$HOME/Documents/apple-notes-mcp/logs/sync.log"
NOTES_DB="$HOME/notes.db"
INDEXER="$HOME/Documents/apple-notes-mcp/scripts/indexer.py"

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

# 记录开始时间
echo "========================================" >> "$LOG_FILE"
echo "$(date): 开始同步" >> "$LOG_FILE"

# 1. 导出备忘录
echo "$(date): 导出备忘录..." >> "$LOG_FILE"
if apple-notes-to-sqlite "$NOTES_DB" >> "$LOG_FILE" 2>&1; then
    echo "$(date): ✓ 导出成功" >> "$LOG_FILE"
else
    echo "$(date): ✗ 导出失败" >> "$LOG_FILE"
    exit 1
fi

# 2. 增量索引
echo "$(date): 更新索引..." >> "$LOG_FILE"
if python3 "$INDEXER" >> "$LOG_FILE" 2>&1; then
    echo "$(date): ✓ 索引成功" >> "$LOG_FILE"
else
    echo "$(date): ✗ 索引失败" >> "$LOG_FILE"
    exit 1
fi

echo "$(date): ✅ 同步完成" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
```

赋予执行权限：
```bash
chmod +x ~/Documents/apple-notes-mcp/scripts/sync.sh
```

#### 步骤 4.2：测试同步脚本

```bash
# 手动运行测试
~/Documents/apple-notes-mcp/scripts/sync.sh

# 查看日志
tail -20 ~/Documents/apple-notes-mcp/logs/sync.log
```

#### 步骤 4.3：配置 fswatch 监控

创建启动脚本 `~/Documents/apple-notes-mcp/scripts/watch.sh`:

```bash
#!/bin/bash

# ==========================
# Apple Notes 文件监控
# ==========================

NOTES_PATH="$HOME/Library/Group Containers/group.com.apple.notes"
SYNC_SCRIPT="$HOME/Documents/apple-notes-mcp/scripts/sync.sh"
LOG_FILE="$HOME/Documents/apple-notes-mcp/logs/watch.log"

echo "$(date): 🔍 开始监控 Apple Notes..." | tee -a "$LOG_FILE"
echo "监控路径: $NOTES_PATH" | tee -a "$LOG_FILE"
echo "按 Ctrl+C 停止" | tee -a "$LOG_FILE"

# 使用 fswatch 监控，60秒防抖
fswatch -o -l 60 "$NOTES_PATH" | while read event; do
    echo "$(date): 检测到变化，触发同步..." | tee -a "$LOG_FILE"
    "$SYNC_SCRIPT"
done
```

赋予执行权限：
```bash
chmod +x ~/Documents/apple-notes-mcp/scripts/watch.sh
```

手动测试：
```bash
# 在终端运行（会一直监控）
~/Documents/apple-notes-mcp/scripts/watch.sh

# 然后在 Apple Notes 中修改一条笔记
# 等待约60秒，应该看到 "检测到变化，触发同步..." 消息
```

#### 步骤 4.4：配置 launchd 开机自启

创建文件 `~/Library/LaunchAgents/com.user.apple-notes-sync.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 服务标识符 -->
    <key>Label</key>
    <string>com.user.apple-notes-sync</string>

    <!-- 执行的命令 -->
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/你的用户名/Documents/apple-notes-mcp/scripts/watch.sh</string>
    </array>

    <!-- 开机自动启动 -->
    <key>RunAtLoad</key>
    <true/>

    <!-- 崩溃后自动重启 -->
    <key>KeepAlive</key>
    <true/>

    <!-- 标准输出日志 -->
    <key>StandardOutPath</key>
    <string>/Users/你的用户名/Documents/apple-notes-mcp/logs/launchd.out</string>

    <!-- 错误输出日志 -->
    <key>StandardErrorPath</key>
    <string>/Users/你的用户名/Documents/apple-notes-mcp/logs/launchd.err</string>
</dict>
</plist>
```

**重要**: 替换文件中的 `你的用户名`

加载服务：
```bash
# 加载 launchd 服务
launchctl load ~/Library/LaunchAgents/com.user.apple-notes-sync.plist

# 验证服务运行状态
launchctl list | grep apple-notes

# 应该看到类似输出：
# 12345  0  com.user.apple-notes-sync
```

停止服务（如果需要）：
```bash
launchctl unload ~/Library/LaunchAgents/com.user.apple-notes-sync.plist
```

#### 步骤 4.5：验证自动化

1. 重启 Mac
2. 打开 Apple Notes，创建或修改一条笔记
3. 等待60秒
4. 检查日志：
   ```bash
   tail -20 ~/Documents/apple-notes-mcp/logs/sync.log
   ```
5. 在 Claude Desktop 中搜索刚才修改的内容，验证已更新

**第4周交付物**：
- ✅ 文件监控自动运行
- ✅ 备忘录修改后自动同步
- ✅ 开机自动启动
- ✅ 日志正常记录

**预计时间**: 3-5小时

---

### 📅 第5周：Poke 集成与优化

**目标**: 实现 iMessage 交互，完成端到端系统

#### 步骤 5.1：修改 MCP 服务器支持 SSE

编辑 `~/Documents/apple-notes-mcp/scripts/server.py`，修改最后一部分：

```python
if __name__ == "__main__":
    import sys

    # 读取命令行参数
    mode = sys.argv[1] if len(sys.argv) > 1 else "stdio"

    if mode == "sse":
        print("🚀 启动 SSE 服务器（用于 Poke）...")
        print("📡 监听端口: 3000")
        mcp.run(transport="sse", port=3000)
    else:
        print("🚀 启动 stdio 服务器（用于 Claude Desktop）...")
        mcp.run(transport="stdio")
```

测试 SSE 模式：
```bash
python3 ~/Documents/apple-notes-mcp/scripts/server.py sse

# 应该看到：
# 📡 监听端口: 3000
```

#### 步骤 5.2：使用 Cloudflare Tunnel 暴露服务

```bash
# 安装 cloudflared
brew install cloudflare/cloudflare/cloudflared

# 启动临时隧道
cloudflared tunnel --url http://localhost:3000
```

会输出类似：
```
2025-11-04 10:00:00 INF +--------------------------------------------------------------------------------------------+
2025-11-04 10:00:00 INF |  Your free tunnel has started! Visit it:                                                  |
2025-11-04 10:00:00 INF |    https://abc-def-ghi.trycloudflare.com                                                   |
2025-11-04 10:00:00 INF +--------------------------------------------------------------------------------------------+
```

**保存这个 URL**（每次运行会变化，后续可配置固定域名）

#### 步骤 5.3：配置 Poke

1. 访问 [poke.com](https://poke.com)
2. 登录你的账号
3. 进入 Settings → Integrations → New Integration
4. 选择 MCP Server
5. 配置：
   - Name: `Apple Notes Search`
   - Transport: `SSE`
   - URL: `https://你的隧道地址.trycloudflare.com/sse`
   - Token: (暂时留空)
6. Save

#### 步骤 5.4：测试 iMessage 集成

1. 打开 iMessage，发送消息给 Poke
2. 测试搜索：
   ```
   搜索我的备忘录中关于机器学习的内容
   ```
3. Poke 应该调用你的 MCP 服务器并返回结果

#### 步骤 5.5：优化搜索结果格式

为了更好的 iMessage 显示，修改 `search_notes` 函数的输出格式：

```python
@mcp.tool(description="在 Apple Notes 中进行语义搜索")
async def search_notes(query: str, limit: int = 3) -> str:
    """优化了 iMessage 显示的版本"""
    try:
        results = collection.query(
            query_texts=[query],
            n_results=limit
        )

        if not results['documents'][0]:
            return "没有找到相关备忘录 😔"

        # 简洁格式（适合手机显示）
        output = [f"找到 {len(results['documents'][0])} 条相关笔记:\n"]

        for i, (doc, metadata) in enumerate(zip(results['documents'][0], results['metadatas'][0])):
            # 截断过长的标题
            title = metadata['title'][:30] + "..." if len(metadata['title']) > 30 else metadata['title']

            # 截断内容
            content = doc[:150] + "..." if len(doc) > 150 else doc

            output.append(f"{i+1}. {title}")
            output.append(f"   {content}")
            output.append(f"   📅 {metadata['updated'][:10]}\n")

        return "\n".join(output)

    except Exception as e:
        return f"搜索失败: {str(e)}"
```

#### 步骤 5.6：配置持久化隧道（可选）

如果不想每次都重新启动 cloudflared：

```bash
# 登录 Cloudflare
cloudflared tunnel login

# 创建隧道
cloudflared tunnel create apple-notes-mcp

# 配置路由
cloudflared tunnel route dns apple-notes-mcp notes.你的域名.com

# 创建配置文件 ~/.cloudflared/config.yml
cat > ~/.cloudflared/config.yml <<EOF
tunnel: <你的隧道ID>
credentials-file: /Users/你的用户名/.cloudflared/<隧道ID>.json

ingress:
  - hostname: notes.你的域名.com
    service: http://localhost:3000
  - service: http_status:404
EOF

# 运行隧道
cloudflared tunnel run apple-notes-mcp
```

**第5周交付物**：
- ✅ MCP 服务器支持 SSE
- ✅ Cloudflare Tunnel 运行
- ✅ Poke 成功集成
- ✅ iMessage 可以搜索备忘录

**预计时间**: 4-6小时

---

## 详细技术文档

### 🔍 ChromaDB 查询语法

```python
# 基础查询
collection.query(
    query_texts=["搜索内容"],
    n_results=5
)

# 带过滤条件
collection.query(
    query_texts=["搜索内容"],
    n_results=5,
    where={"updated": {"$gte": "2025-01-01"}}
)

# 复杂过滤
collection.query(
    query_texts=["搜索内容"],
    where={
        "$and": [
            {"updated": {"$gte": "2025-01-01"}},
            {"title": {"$contains": "项目"}}
        ]
    }
)
```

### 📊 元数据过滤操作符

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `$eq` | 等于 | `{"title": {"$eq": "笔记"}}` |
| `$ne` | 不等于 | `{"title": {"$ne": "草稿"}}` |
| `$gt` | 大于 | `{"updated": {"$gt": "2025-01-01"}}` |
| `$gte` | 大于等于 | `{"updated": {"$gte": "2025-01-01"}}` |
| `$lt` | 小于 | `{"created": {"$lt": "2024-12-31"}}` |
| `$lte` | 小于等于 | `{"created": {"$lte": "2024-12-31"}}` |
| `$contains` | 包含 | `{"title": {"$contains": "机器学习"}}` |
| `$and` | 与 | `{"$and": [{...}, {...}]}` |
| `$or` | 或 | `{"$or": [{...}, {...}]}` |

### 🧠 DeepSeek V3 多步搜索示例

```python
# 用户问题："找到我最近写的关于深度学习项目的笔记"

# 第1步：初始搜索
search_notes("深度学习 项目", limit=10)

# DeepSeek 分析：发现结果太多，需要缩小范围
# 第2步：精细化搜索
refine_search(
    query="深度学习 NLP 项目",
    date_after="2025-10-01",
    limit=5
)

# DeepSeek 综合：找到3条最相关的笔记，返回给用户
```

### 🛠️ 故障排查指南

#### 问题 1：apple-notes-to-sqlite 权限被拒绝

**错误信息**：
```
Operation not permitted
```

**解决方法**：
1. 打开"系统设置"
2. 隐私与安全 → 完全磁盘访问
3. 点击 `+` 添加 Terminal（或你使用的终端）
4. 重启终端

#### 问题 2：ChromaDB 导入失败

**错误信息**：
```
ImportError: cannot import name 'ClientAPI'
```

**解决方法**：
```bash
pip3 install --upgrade chromadb
```

#### 问题 3：MCP 服务器未在 Claude 中显示

**检查清单**：
- [ ] 配置文件路径是绝对路径（不要用 `~`）
- [ ] Python 脚本有执行权限（`chmod +x`）
- [ ] 完全退出并重启 Claude Desktop
- [ ] 检查日志：`tail -f ~/Library/Logs/Claude/mcp*.log`

#### 问题 4：fswatch 触发太频繁

**解决方法**：
增加防抖延迟：
```bash
fswatch -o -l 120 ...  # 从60秒改为120秒
```

#### 问题 5：launchd 服务没有启动

**检查方法**：
```bash
# 查看服务列表
launchctl list | grep apple-notes

# 查看错误日志
cat ~/Documents/apple-notes-mcp/logs/launchd.err

# 重新加载
launchctl unload ~/Library/LaunchAgents/com.user.apple-notes-sync.plist
launchctl load ~/Library/LaunchAgents/com.user.apple-notes-sync.plist
```

---

## 学习资源

### 📚 必读教程

1. **MCP 官方文档**
   - [Getting Started](https://modelcontextprotocol.io/introduction)
   - [Building MCP Servers](https://modelcontextprotocol.io/docs/concepts/servers)

2. **Microsoft MCP for Beginners**
   - 仓库：https://github.com/microsoft/mcp-for-beginners
   - 重点：Module 3（第一个服务器）、Module 11（数据库集成）

3. **alejandro-ao MCP 教程**
   - YouTube：https://youtu.be/Ek8JHgZtmcI
   - GitHub：https://github.com/alejandro-ao/mcp-server-example
   - 适合零基础

4. **ChromaDB Cookbook**
   - 地址：https://cookbook.chromadb.dev
   - 重点：基础查询、元数据过滤

5. **FastEmbed 文档**
   - 地址：https://qdrant.github.io/fastembed
   - 重点：模型选择、性能优化

### 🎥 视频教程

- **终端基础**：搜索 "Mac Terminal for Beginners"
- **Python 入门**：Coursera "Python for Everybody"
- **MCP 实战**：alejandro-ao 的 YouTube 频道

### 💬 社区支持

- **MCP Discord**：https://discord.gg/modelcontextprotocol
- **r/ClaudeAI**：Reddit 社区
- **Stack Overflow**：标签 `model-context-protocol`

---

## 成本预算

### 💰 详细成本分析

#### 一次性成本
| 项目 | 费用 | 备注 |
|------|------|------|
| Mac Studio M2 Max | $0 | 已有 |
| 学习时间投入 | 25-37小时 | 5周 × 5-7小时/周 |

#### 月度成本
| 项目 | 费用 | 备注 |
|------|------|------|
| DeepSeek API | $5-10 | 个人使用量低 |
| Poke 订阅 | $3-30 | 根据使用量 |
| Cloudflare Tunnel | $0 | 免费版足够 |
| **月度合计** | **$8-40** | |

#### 年度成本
| 项目 | 费用 |
|------|------|
| DeepSeek API | $60-120 |
| Poke | $36-360 |
| 电费（Mac Studio 24小时运行） | ~$20 |
| **年度合计** | **$116-500** |

### 💡 成本优化建议

1. **DeepSeek API**：
   - 使用缓存减少重复调用
   - 设置每日限额（$1-2/天）

2. **Poke**：
   - 评估使用频率，可能选择较低套餐
   - 或替代方案：直接用 AppleScript 发 iMessage（免费但复杂）

3. **Cloudflare Tunnel**：
   - 免费版足够个人使用
   - 如果需要固定域名，购买域名 $10-15/年

---

## 常见问题 FAQ

### Q1：必须会编程吗？

**答**：不必精通，但需要学习基础：
- 能看懂 Python 代码（变量、函数、循环）
- 会用终端执行命令（`cd`、`ls`、`python3`）
- 能编辑配置文件（JSON、YAML）

推荐先花2-3天学习 Python 基础。

---

### Q2：能否跳过某些步骤？

**可以简化的**：
- 第4周（自动化）：可以先手动运行同步脚本
- 第5周（Poke）：可以只用 Claude Desktop

**不能跳过的**：
- 第1周（环境搭建）
- 第2周（向量搜索）
- 第3周（MCP 服务器）

---

### Q3：M1 或 Intel Mac 可以吗？

**答**：可以！所有技术都支持：
- M1/M2/M3：性能最佳
- Intel Mac：也能运行，稍慢但够用

---

### Q4：数据会上传到云端吗？

**答**：
- ✅ **本地**：备忘录、SQLite、ChromaDB 都在本地
- ⚠️ **云端**：仅 DeepSeek API 会接收搜索结果（不是全部笔记）
- 💡 **完全本地方案**：可以替换为 Ollama（本地 LLM），但配置复杂

---

### Q5：支持中文备忘录吗？

**答**：完全支持！
- ChromaDB 支持多语言
- BGE 模型对中文效果很好
- 搜索中英文混合内容无问题

---

### Q6：能搜索附件（PDF、图片）吗？

**答**：
- 当前方案：不支持
- 后期扩展：
  - PDF：使用 PyPDF2 提取文本
  - 图片：使用 Tesseract OCR 或 CLIP（multimodal）
  - 难度：中等，需额外2-3周

---

### Q7：备忘录数量上限？

**答**：
- ChromaDB 理论支持百万级
- 1000条笔记下，搜索速度 <50ms
- 1万条笔记下，搜索速度 <200ms
- 建议定期清理旧笔记归档

---

### Q8：出错了怎么办？

**步骤**：
1. 查看错误日志
2. Google 搜索错误信息
3. 在本文档"故障排查"部分查找
4. 在 MCP Discord 社区求助
5. 提供完整错误日志和操作步骤

---

## 下一步行动检查清单

### ✅ 准备阶段
- [ ] 确认 Mac 型号和 macOS 版本（需 macOS 12+）
- [ ] 备份重要备忘录（以防万一）
- [ ] 预留 25-37 小时学习时间
- [ ] 加入 MCP Discord 社区

### ✅ 第1周
- [ ] 安装 Homebrew
- [ ] 安装 Python 工具
- [ ] 测试 apple-notes-to-sqlite
- [ ] 创建项目目录

### ✅ 第2周
- [ ] 编写索引脚本
- [ ] 全量索引所有笔记
- [ ] 测试语义搜索
- [ ] 验证增量更新

### ✅ 第3周
- [ ] 创建 MCP 服务器
- [ ] 配置 Claude Desktop
- [ ] 测试所有工具
- [ ] 验证搜索准确性

### ✅ 第4周
- [ ] 编写同步脚本
- [ ] 配置 fswatch 监控
- [ ] 设置 launchd 服务
- [ ] 测试自动化流程

### ✅ 第5周
- [ ] 修改服务器支持 SSE
- [ ] 安装 Cloudflare Tunnel
- [ ] 配置 Poke 集成
- [ ] 端到端测试

---

## 项目文件清单

完成后，你的项目目录应该是这样的：

```
~/Documents/apple-notes-mcp/
├── scripts/
│   ├── indexer.py          # 索引脚本
│   ├── server.py           # MCP 服务器
│   ├── sync.sh             # 同步脚本
│   └── watch.sh            # 监控脚本
├── logs/
│   ├── sync.log            # 同步日志
│   ├── watch.log           # 监控日志
│   ├── launchd.out         # launchd 输出
│   └── launchd.err         # launchd 错误
├── chroma_db/              # ChromaDB 数据目录
├── .last_sync              # 上次同步时间戳
├── conversation-log.md     # 对话记录（本文件）
└── implementation-plan.md  # 实施方案（你正在阅读）

~/notes.db                  # SQLite 备忘录数据库

~/Library/LaunchAgents/
└── com.user.apple-notes-sync.plist  # launchd 配置

~/Library/Application Support/Claude/
└── claude_desktop_config.json       # Claude MCP 配置
```

---

## 成功标准

项目完成后，你应该能够：

1. ✅ 在 Apple Notes 中创建/修改笔记，60秒内自动同步
2. ✅ 在 Claude Desktop 中搜索笔记，返回最相关的5条
3. ✅ 通过 iMessage 发送搜索请求，Poke 返回结果
4. ✅ 使用精细化搜索（日期范围、关键词组合）
5. ✅ 手动刷新索引（当需要立即同步时）
6. ✅ 查看统计信息（笔记总数、索引状态）
7. ✅ 多步搜索（AI 先广泛搜索→分析→精细搜索）

---

## 维护计划

### 每周
- [ ] 检查同步日志，确保无错误
- [ ] 测试搜索功能，验证准确性

### 每月
- [ ] 更新 Python 依赖：`pip3 install --upgrade chromadb fastembed mcp`
- [ ] 清理旧日志：`rm ~/Documents/apple-notes-mcp/logs/*.log.old`

### 每季度
- [ ] 备份 ChromaDB 数据库：`tar -czf chroma_backup.tar.gz ~/Documents/apple-notes-mcp/chroma_db`
- [ ] 重新评估 DeepSeek API 用量和成本

---

## 扩展功能（未来）

完成基础系统后，可以考虑：

### 🔮 第6周+：高级功能

1. **OCR 图片识别**
   - 集成 Tesseract
   - 索引图片中的文字
   - 难度：中

2. **知识图谱可视化**
   - 使用 WeKnora
   - 展示笔记关系网络
   - 难度：高

3. **自动标签建议**
   - 使用 LLM 分析内容
   - 自动添加相关标签
   - 难度：中

4. **定期摘要**
   - 每周发送笔记摘要到邮箱
   - 总结本周重点内容
   - 难度：低

5. **语音输入**
   - 集成 Whisper（语音转文字）
   - iMessage 发送语音搜索
   - 难度：中

6. **多设备同步**
   - 部署到云服务器
   - iPhone/iPad 随时访问
   - 难度：中

---

## 结语

这个项目虽然对零基础用户有一定挑战，但每个步骤都有详细说明。关键是：

1. **循序渐进**：不要跳步，一步一步来
2. **善用日志**：出错时查看日志是最快的调试方法
3. **寻求帮助**：社区很友好，不要怕提问
4. **享受过程**：从零到一搭建系统，很有成就感！

如果遇到困难，随时回到这份文档查找答案。祝你成功搭建自己的智能备忘录系统！

---

**版本历史**：
- v1.0 (2025-11-04): 初始版本

**作者**: Claude + 你
**许可**: 个人使用

---

*本文档将随项目进展持续更新*
