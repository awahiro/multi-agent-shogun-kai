#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# attatch.sh - multiagentセッションにアタッチ
# ═══════════════════════════════════════════════════════════════════════════════
# レイアウト（8ペイン統合）:
#   +------------+------------+----------+----------+----------+
#   | dashboard  |   将軍     |   侍1    |   侍2    |   侍3    |
#   |   (0)      |   (1)      |   (2)    |   (3)    |   (4)    |
#   |   20%      |   20%      +----------+----------+----------+
#   |            |            |  足軽1   |  足軽2   |  忍者    |
#   |            |            |   (5)    |   (6)    |   (7)    |
#   +------------+------------+----------+----------+----------+
#
# 使用方法:
#   ./attatch.sh           # セッションにアタッチ
#   ./attatch.sh -h        # ヘルプ表示
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# スクリプトのディレクトリに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo ""
            echo "🏯 attatch.sh - multiagentセッションにアタッチ"
            echo ""
            echo "使用方法: ./attatch.sh [オプション]"
            echo ""
            echo "オプション:"
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

# セッション名をファイルから読み込み
if [ ! -f ".session-name" ]; then
    echo "【警】.session-name が存在しません"
    echo "      先に ./shutsujin_departure.sh を実行してください"
    exit 1
fi

SESSION_NAME=$(cat .session-name)

# セッションが存在するか確認
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "【警】$SESSION_NAME セッションが存在しません"
    echo "      先に ./shutsujin_departure.sh を実行してください"
    exit 1
fi

echo "【報】$SESSION_NAME セッションにアタッチします..."
tmux attach-session -t "$SESSION_NAME"
