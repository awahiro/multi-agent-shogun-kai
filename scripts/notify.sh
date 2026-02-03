#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# notify.sh - tmux send-keys ヘルパースクリプト
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/notify.sh <pane> <message>
#
# 例:
#   SESSION_NAME=$(cat .session-name)
#   ./scripts/notify.sh ${SESSION_NAME}:0.1 "タスク完了。報告書を更新した。"
#   ./scripts/notify.sh ${SESSION_NAME}:0.2 "queue/tasks/3_samurai1.yaml を確認せよ。"
#
# 注意:
#   - 2回のsend-keys呼び出しを1コマンドで実行
#   - メッセージにシングルクォートが含まれる場合はダブルクォートで囲む
#   - SESSION_NAME は .session-name ファイルから取得
# ═══════════════════════════════════════════════════════════════════════════════

if [ $# -lt 2 ]; then
    echo "使用法: $0 <pane> <message>"
    echo "例: SESSION_NAME=\$(cat .session-name) && $0 \${SESSION_NAME}:0.1 'タスク完了'"
    exit 1
fi

PANE="$1"
MESSAGE="$2"

# メッセージを送信
tmux send-keys -t "$PANE" "$MESSAGE"
# Enterを送信
tmux send-keys -t "$PANE" Enter
