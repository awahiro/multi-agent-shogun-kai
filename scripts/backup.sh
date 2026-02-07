#!/bin/bash
# 📦 multi-agent-shogun バックアップスクリプト
# Backup Script for Multi-Agent Orchestration System
#
# 使用方法:
#   ./scripts/backup.sh           # 通常バックアップ（内容がある場合のみ）
#   ./scripts/backup.sh -f        # 強制バックアップ（内容に関係なく実行）
#   ./scripts/backup.sh -h        # ヘルプ表示
#
# 戻り値:
#   0: バックアップ成功
#   1: バックアップ不要（内容なし）
#   2: エラー

set -e

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
FORCE_BACKUP=false
QUIET_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_BACKUP=true
            shift
            ;;
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        -h|--help)
            echo ""
            echo "📦 multi-agent-shogun バックアップスクリプト"
            echo ""
            echo "使用方法: ./scripts/backup.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -f, --force    強制バックアップ（内容に関係なく実行）"
            echo "  -q, --quiet    静かモード（メッセージを抑制）"
            echo "  -h, --help     このヘルプを表示"
            echo ""
            echo "バックアップ対象:"
            echo "  - dashboard.md"
            echo "  - queue/reports/"
            echo "  - queue/tasks/"
            echo "  - queue/shogun_to_karo.yaml (存在する場合)"
            echo ""
            echo "保存先: ./logs/backup_YYYYMMDD_HHMMSS/"
            echo ""
            echo "※ 元ファイルの初期化は ./scripts/task_init.sh を使用"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./scripts/backup.sh -h でヘルプを表示"
            exit 2
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════════
# ログ関数
# ═══════════════════════════════════════════════════════════════════════════════
log_info() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "\033[1;33m【報】\033[0m $1"
    fi
}

log_success() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "\033[1;32m【成】\033[0m $1"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# バックアップ実行
# ═══════════════════════════════════════════════════════════════════════════════
BACKUP_DIR="./logs/backup_$(date '+%Y%m%d_%H%M%S')"
NEED_BACKUP=false

# バックアップが必要か判定
# 条件: 戦果セクションに完了タスクがある（"✅" が含まれる）
if [ "$FORCE_BACKUP" = true ]; then
    NEED_BACKUP=true
elif [ -f "./dashboard.md" ]; then
    # 戦果セクションに完了マーク（✅）があればバックアップ対象
    if grep -q "✅" "./dashboard.md" 2>/dev/null; then
        NEED_BACKUP=true
    # または任意のタスクID形式（cmd_, poem_, task_ 等）があればバックアップ対象
    elif grep -qE "(cmd_|poem_|task_)" "./dashboard.md" 2>/dev/null; then
        NEED_BACKUP=true
    fi
fi

# バックアップ実行
if [ "$NEED_BACKUP" = true ]; then
    mkdir -p "$BACKUP_DIR" || true
    cp "./dashboard.md" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "./queue/reports" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "./queue/tasks" "$BACKUP_DIR/" 2>/dev/null || true
    # 旧形式のファイルもバックアップ（存在する場合）
    cp "./queue/shogun_to_karo.yaml" "$BACKUP_DIR/" 2>/dev/null || true
    log_success "📦 バックアップ完了: $BACKUP_DIR"

    # バックアップディレクトリのパスを出力（他スクリプトから利用可能）
    echo "$BACKUP_DIR"
    exit 0
else
    log_info "📦 バックアップ不要（タスク記録なし）"
    exit 1
fi
