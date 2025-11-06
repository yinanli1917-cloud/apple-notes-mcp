#!/bin/bash
# Apple Notes MCP HTTP 服务器启动脚本
# 用于 Poke AI 集成

echo "=================================="
echo "Apple Notes MCP - Poke AI 服务器"
echo "=================================="
echo ""

cd ~/Documents/apple-notes-mcp/scripts

# 检查是否已有服务器在运行
if lsof -i :8000 > /dev/null 2>&1; then
    echo "⚠️  端口 8000 已被占用"
    echo ""
    echo "正在运行的进程："
    lsof -i :8000
    echo ""
    read -p "是否要停止现有服务器并重启？(y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PID=$(lsof -t -i :8000)
        kill $PID
        echo "✅ 已停止旧服务器 (PID: $PID)"
        sleep 2
    else
        echo "❌ 取消启动"
        exit 1
    fi
fi

echo "🚀 正在启动 HTTP MCP 服务器..."
echo ""
echo "服务器地址: http://127.0.0.1:8000/sse"
echo "用于 Poke AI 配置"
echo ""
echo "按 Ctrl+C 停止服务器"
echo "=================================="
echo ""

# 启动服务器
/opt/homebrew/bin/python3.12 server_http.py
