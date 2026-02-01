#!/bin/bash
# 全軍撤収スクリプト

cd "$(dirname "${BASH_SOURCE[0]}")"

SESSION_NAME=$(cat .session-name 2>/dev/null || echo "multiagent")

echo "🏯 全軍撤収中..."
tmux kill-session -t "$SESSION_NAME" 2>/dev/null && echo "  ✓ $SESSION_NAME 終了" || echo "  - セッションなし"
echo "撤収完了！"
