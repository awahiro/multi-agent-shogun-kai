#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# report_watcher.sh - 報告ファイル監視・自動通知スクリプト
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/report_watcher.sh           # フォアグラウンドで起動
#   ./scripts/report_watcher.sh &         # バックグラウンドで起動
#   ./scripts/report_watcher.sh --stop    # 停止
#   ./scripts/report_watcher.sh -h        # ヘルプ表示
#
# 機能:
#   - queue/reports/*.yaml の変更を監視
#   - ファイル更新を検出したら将軍に自動通知
#   - エージェントが notify.sh を忘れても検出可能
#
# クロスプラットフォーム対応:
#   - Linux/WSL: inotifywait (inotify-tools)
#   - macOS: fswatch (brew install fswatch)
#   - Windows: WSL経由で使用
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# PIDファイル
PID_FILE=".report_watcher.pid"

# ヘルプ表示
show_help() {
    echo ""
    echo "📡 report_watcher.sh - 報告ファイル監視・自動通知"
    echo ""
    echo "使用法:"
    echo "  ./scripts/report_watcher.sh           # フォアグラウンドで起動"
    echo "  ./scripts/report_watcher.sh &         # バックグラウンドで起動"
    echo "  ./scripts/report_watcher.sh --stop    # 停止"
    echo "  ./scripts/report_watcher.sh -h        # このヘルプを表示"
    echo ""
    echo "機能:"
    echo "  - queue/reports/*.yaml の変更を監視"
    echo "  - ファイル更新を検出したら将軍に自動通知"
    echo "  - エージェントが notify.sh を忘れても検出可能"
    echo ""
    echo "対応OS:"
    echo "  - Linux/WSL: inotifywait (inotify-tools)"
    echo "  - macOS: fswatch (brew install fswatch)"
    echo ""
    exit 0
}

# 停止処理
stop_watcher() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "【報】report_watcher を停止中... (PID: $PID)"
            kill "$PID" 2>/dev/null || true
            rm -f "$PID_FILE"
            echo "【成】停止完了"
        else
            echo "【報】プロセスは既に停止しています"
            rm -f "$PID_FILE"
        fi
    else
        echo "【報】PIDファイルが見つかりません"
    fi
    exit 0
}

# セッション名を取得
get_session_name() {
    if [ -f ".session-name" ]; then
        cat .session-name
    else
        echo ""
    fi
}

# ファイル変更時の処理
on_file_change() {
    local file="$1"
    local session_name
    session_name=$(get_session_name)

    if [ -z "$session_name" ]; then
        echo "【警】セッション名が取得できません"
        return
    fi

    # ファイル名からエージェント名を抽出
    local basename
    basename=$(basename "$file")
    local agent_name=""

    case "$basename" in
        3_samurai1_report*)  agent_name="侍1" ;;
        3_samurai2_report*)  agent_name="侍2" ;;
        3_samurai3_report*)  agent_name="侍3" ;;
        4_ashigaru1_report*) agent_name="足軽1" ;;
        4_ashigaru2_report*) agent_name="足軽2" ;;
        7_ninja_report*)     agent_name="忍者" ;;
        *) agent_name="不明" ;;
    esac

    # 将軍に通知
    echo "【検】報告ファイル更新: $agent_name ($basename)"
    ./scripts/notify.sh "${session_name}:0.1" "監視犬" "${agent_name}の報告ファイルが更新された。確認せよ。"
}

# inotifywait を使った監視 (Linux/WSL)
watch_with_inotify() {
    echo "【報】inotifywait で監視開始..."
    inotifywait -m -e modify,create --format '%w%f' "$PROJECT_ROOT/queue/reports/" 2>/dev/null |
    while read -r file; do
        # YAMLファイルのみ処理
        if [[ "$file" == *.yaml ]]; then
            on_file_change "$file"
        fi
    done
}

# fswatch を使った監視 (macOS)
watch_with_fswatch() {
    echo "【報】fswatch で監視開始..."
    fswatch -0 "$PROJECT_ROOT/queue/reports/" 2>/dev/null |
    while IFS= read -r -d '' file; do
        # YAMLファイルのみ処理
        if [[ "$file" == *.yaml ]]; then
            on_file_change "$file"
        fi
    done
}

# 引数解析
case "${1:-}" in
    -h|--help)
        show_help
        ;;
    --stop)
        stop_watcher
        ;;
esac

# 既に起動中かチェック
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "【警】report_watcher は既に起動中です (PID: $OLD_PID)"
        echo "     停止するには: ./scripts/report_watcher.sh --stop"
        exit 1
    else
        rm -f "$PID_FILE"
    fi
fi

# PIDファイル作成
echo $$ > "$PID_FILE"

# トラップ設定（終了時にPIDファイル削除）
trap 'rm -f "$PID_FILE"; exit' INT TERM EXIT

# queue/reports ディレクトリが存在するか確認
if [ ! -d "$PROJECT_ROOT/queue/reports" ]; then
    echo "【警】queue/reports ディレクトリが存在しません"
    mkdir -p "$PROJECT_ROOT/queue/reports"
fi

echo ""
echo "📡 report_watcher.sh 起動"
echo "   監視対象: queue/reports/*.yaml"
echo "   通知先: 将軍 (pane 0.1)"
echo "   停止: ./scripts/report_watcher.sh --stop"
echo ""

# プラットフォーム検出と監視開始
if command -v inotifywait &> /dev/null; then
    watch_with_inotify
elif command -v fswatch &> /dev/null; then
    watch_with_fswatch
else
    echo ""
    echo "【エラー】ファイル監視ツールが見つかりません"
    echo ""
    echo "インストール方法:"
    echo "  Linux/WSL: sudo apt install inotify-tools"
    echo "  macOS:     brew install fswatch"
    echo ""
    rm -f "$PID_FILE"
    exit 1
fi
