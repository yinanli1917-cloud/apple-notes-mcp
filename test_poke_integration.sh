#!/bin/bash
# 测试 Poke AI 集成配置

echo "=================================="
echo "Poke AI 集成测试"
echo "=================================="
echo ""

# 测试 1: 检查 server_http.py 是否存在
echo "测试 1: 检查文件..."
if [ -f ~/Documents/apple-notes-mcp/scripts/server_http.py ]; then
    echo "✅ server_http.py 存在"
else
    echo "❌ server_http.py 不存在"
    exit 1
fi

# 测试 2: 检查向量数据库
echo ""
echo "测试 2: 检查向量数据库..."
if [ -d ~/Documents/apple-notes-mcp/chroma_db ]; then
    echo "✅ ChromaDB 存在"
    # 统计大小
    size=$(du -sh ~/Documents/apple-notes-mcp/chroma_db | cut -f1)
    echo "   数据库大小: $size"
else
    echo "⚠️  向量数据库不存在，需要先运行索引"
    echo "   运行: cd ~/Documents/apple-notes-mcp/scripts && python3 indexer.py"
fi

# 测试 3: 检查笔记数据库
echo ""
echo "测试 3: 检查笔记数据库..."
if [ -f ~/notes.db ]; then
    echo "✅ notes.db 存在"
    # 统计笔记数
    count=$(sqlite3 ~/notes.db "SELECT COUNT(*) FROM notes" 2>/dev/null)
    if [ ! -z "$count" ]; then
        echo "   笔记总数: $count"
    fi
else
    echo "⚠️  笔记数据库不存在，需要先导出笔记"
    echo "   运行: cd ~/Documents/apple-notes-mcp/scripts && python3 export_notes_fixed.py"
fi

# 测试 4: 检查 Python 依赖
echo ""
echo "测试 4: 检查 Python 依赖..."
python3 -c "import fastmcp" 2>/dev/null && echo "✅ fastmcp 已安装" || echo "❌ fastmcp 未安装"
python3 -c "import chromadb" 2>/dev/null && echo "✅ chromadb 已安装" || echo "❌ chromadb 未安装"
python3 -c "from FlagEmbedding import FlagModel" 2>/dev/null && echo "✅ FlagEmbedding 已安装" || echo "❌ FlagEmbedding 未安装"

# 测试 5: 检查端口是否可用
echo ""
echo "测试 5: 检查端口 8000..."
if lsof -i :8000 > /dev/null 2>&1; then
    echo "⚠️  端口 8000 已被占用"
    lsof -i :8000
else
    echo "✅ 端口 8000 可用"
fi

# 总结
echo ""
echo "=================================="
echo "配置总结"
echo "=================================="
echo ""
echo "如果所有测试都通过，你可以："
echo ""
echo "1. 启动服务器："
echo "   cd ~/Documents/apple-notes-mcp"
echo "   ./start_poke_server.sh"
echo ""
echo "2. 在 Poke AI 中配置："
echo "   Server URL: http://127.0.0.1:8000/sse"
echo ""
echo "详细文档: ~/Documents/apple-notes-mcp/POKE_INTEGRATION.md"
echo ""
