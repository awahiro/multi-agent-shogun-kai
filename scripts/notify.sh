#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# notify.sh - tmux send-keys ヘルパースクリプト
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/notify.sh <pane> <sender> <message>
#
# 例:
#   SESSION_NAME=$(cat .session-name)
#   ./scripts/notify.sh ${SESSION_NAME}:0.1 "忍者" "タスク完了。報告書を更新した。"
#   ./scripts/notify.sh ${SESSION_NAME}:0.2 "侍1" "queue/tasks/3_samurai1.yaml を確認せよ。"
#
# 出力形式:
#   忍者> タスク完了。報告書を更新した。
#
# 注意:
#   - 2回のsend-keys呼び出しを1コマンドで実行
#   - メッセージにシングルクォートが含まれる場合はダブルクォートで囲む
#   - SESSION_NAME は .session-name ファイルから取得
# ═══════════════════════════════════════════════════════════════════════════════

if [ $# -lt 3 ]; then
    echo "使用法: $0 <pane> <sender> <message>"
    echo "例: SESSION_NAME=\$(cat .session-name) && $0 \${SESSION_NAME}:0.1 '忍者' 'タスク完了'"
    exit 1
fi

PANE="$1"
SENDER="$2"
MESSAGE="$3"

# 送信者付きメッセージを送信
tmux send-keys -t "$PANE" "${SENDER}> ${MESSAGE}"
# Enterを送信
tmux send-keys -t "$PANE" Enter
