#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# post_complete.sh - タスク完了後の処理を一括実行
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/post_complete.sh           # 完了後処理を実行
#   ./scripts/post_complete.sh --force   # 未報告があっても強制実行
#   ./scripts/post_complete.sh -h        # ヘルプ表示
#
# 処理内容:
#   1. 未報告エージェントのチェック
#   2. ./scripts/compact.sh --auto（自動検出でcompact）
#   3. ./scripts/backup.sh（バックアップ取得）
#   4. ./scripts/task_init.sh（タスク・報告ファイル初期化）
#
# 注意:
#   - 未報告エージェントがいる場合は警告して停止
#   - --force で強制実行可能（非推奨）
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# オプション
FORCE_MODE=false

# ヘルプ表示
show_help() {
    echo ""
    echo "🏁 post_complete.sh - タスク完了後の処理を一括実行"
    echo ""
    echo "使用法:"
    echo "  ./scripts/post_complete.sh           # 完了後処理を実行"
    echo "  ./scripts/post_complete.sh --force   # 未報告があっても強制実行"
    echo "  ./scripts/post_complete.sh -h        # このヘルプを表示"
    echo ""
    echo "処理内容:"
    echo "  1. 未報告エージェントのチェック"
    echo "  2. compact.sh --auto（自動検出でcompact）"
    echo "  3. backup.sh（バックアップ取得）"
    echo "  4. task_init.sh（タスク・報告ファイル初期化）"
    echo ""
    echo "注意:"
    echo "  - 未報告エージェントがいる場合は警告して停止"
    echo "  - compact.sh はタスクファイルから実行エージェントを検出"
    echo "  - compact.sh は task_init.sh 前に実行（タスクファイルが必要）"
    echo ""
    exit 0
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        --force)
            FORCE_MODE=true
            shift
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./scripts/post_complete.sh -h でヘルプを表示"
            exit 2
            ;;
    esac
done

echo ""
echo "🏁 タスク完了後の処理を開始..."
echo ""

# Step 1: 未報告エージェントのチェック
echo "【報】Step 1: 未報告エージェントをチェック中..."
if ! ./scripts/check_pending.sh -q; then
    # 未報告エージェントあり
    ./scripts/check_pending.sh  # 詳細表示

    if [ "$FORCE_MODE" = true ]; then
        echo "【警】--force が指定されたため、強制的に続行します"
    else
        echo ""
        echo "【停】未報告エージェントがいるため、処理を中断しました"
        echo ""
        echo "対処方法:"
        echo "  1. リマインダーを送信: ./scripts/check_pending.sh --remind"
        echo "  2. 強制実行: ./scripts/post_complete.sh --force"
        echo ""
        exit 1
    fi
else
    echo "  └─ 全エージェントの報告が完了しています"
fi
echo ""

# Step 2: compact.sh --auto
echo "【報】Step 2: エージェントの /compact を実行中..."
./scripts/compact.sh --auto
echo ""

# Step 3: backup.sh
echo "【報】Step 3: バックアップを取得中..."
./scripts/backup.sh
echo ""

# Step 4: task_init.sh
echo "【報】Step 4: タスク・報告ファイルを初期化中..."
./scripts/task_init.sh
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "【成】タスク完了後の処理が全て完了しました"
echo ""
echo "次のステップ:"
echo "  - dashboard.md の「進行中」セクションをクリア"
echo "  - 殿に完了報告"
echo "═══════════════════════════════════════════════════════════════"
