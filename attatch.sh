#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# attatch.sh - 統合ビューア（dashboard + shogun + multiagent 1画面表示）
# ═══════════════════════════════════════════════════════════════════════════════
# レイアウト (3列):
#   +-----------+----------------+---------------------------+
#   |           |                |                           |
#   | dashboard |     将軍       |        multiagent         |
#   |  (3秒     |    (shogun)    |   (侍×2, 足軽×2, 忍者)   |
#   |   更新)   |                |                           |
#   |           |                |                           |
#   +-----------+----------------+---------------------------+
#
# 使用方法:
#   ./attatch.sh           # 統合セッション作成＆アタッチ
#   ./attatch.sh -d        # デタッチ状態で作成のみ
# ═══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_NAME="shogun-all"

# オプション解析
DETACHED=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--detach)
            DETACHED=true
            shift
            ;;
        -h|--help)
            echo ""
            echo "🏯 attatch.sh - 統合ビューア"
            echo ""
            echo "使用方法: ./attatch.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -d, --detach    デタッチ状態で作成のみ"
            echo "  -h, --help      このヘルプを表示"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            exit 1
            ;;
    esac
done

# 既存セッションがあればアタッチ
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "【報】既存の統合セッション '$SESSION_NAME' にアタッチします..."
    if [ "$DETACHED" = false ]; then
        tmux attach-session -t "$SESSION_NAME"
    else
        echo "【成】セッション '$SESSION_NAME' は既に存在します"
    fi
    exit 0
fi

# shogun と multiagent セッションが存在するか確認
if ! tmux has-session -t "shogun" 2>/dev/null; then
    echo "【警】shogun セッションが存在しません"
    echo "      先に ./shutsujin_departure.sh を実行してください"
    exit 1
fi

if ! tmux has-session -t "multiagent" 2>/dev/null; then
    echo "【警】multiagent セッションが存在しません"
    echo "      先に ./shutsujin_departure.sh を実行してください"
    exit 1
fi

echo ""
echo "🏯 統合ビュー作成中..."
echo ""

# 新しいセッションを作成
tmux new-session -d -s "$SESSION_NAME" -x 280 -y 60

# ウィンドウ名を設定
tmux rename-window -t "$SESSION_NAME:0" "統合"

# 3列レイアウトを作成
# 最初に左右分割（左20%がdashboard、右80%が残り）
tmux split-window -h -t "$SESSION_NAME:0" -p 80

# 右側（pane 1）を左右分割（shogun + multiagent）
tmux split-window -h -t "$SESSION_NAME:0.1" -p 60

# Pane 0: dashboard (3秒ごとに更新)
tmux send-keys -t "$SESSION_NAME:0.0" "watch -n 3 -c 'cat $SCRIPT_DIR/dashboard.md'" C-m

# Pane 1: shogun セッションにアタッチ
tmux send-keys -t "$SESSION_NAME:0.1" "unset TMUX && tmux attach-session -t shogun" C-m

# Pane 2: multiagent セッションにアタッチ
tmux send-keys -t "$SESSION_NAME:0.2" "unset TMUX && tmux attach-session -t multiagent" C-m

# shogunペインを選択
tmux select-pane -t "$SESSION_NAME:0.1"

echo "【成】統合ビュー '$SESSION_NAME' を作成しました"
echo ""
echo "レイアウト (3列):"
echo "  +-----------+----------------+---------------------------+"
echo "  |           |                |                           |"
echo "  | dashboard |     将軍       |        multiagent         |"
echo "  |  (3秒     |    (shogun)    |   (侍×2, 足軽×2, 忍者)   |"
echo "  |   更新)   |                |                           |"
echo "  |           |                |                           |"
echo "  +-----------+----------------+---------------------------+"
echo ""
echo "操作方法:"
echo "  Ctrl+b → 矢印キー  : ペイン間移動"
echo "  Ctrl+b → d         : デタッチ（バックグラウンド）"
echo ""

if [ "$DETACHED" = false ]; then
    echo "【報】アタッチします..."
    tmux attach-session -t "$SESSION_NAME"
else
    echo "【報】アタッチするには: tmux attach -t $SESSION_NAME"
fi
