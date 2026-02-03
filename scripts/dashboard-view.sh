#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# dashboard-view.sh - スクロール可能なdashboard表示
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/dashboard-view.sh [dashboard.mdのパス]
#
# 操作:
#   Ctrl+C  - 表示を一時停止（その後lessでスクロール可能）
#   q       - lessを終了して自動更新に戻る
#   Ctrl+C 2回 - 完全終了
# ═══════════════════════════════════════════════════════════════════════════════

DASHBOARD_FILE="${1:-dashboard.md}"
INTERVAL=2

trap 'echo ""; echo "スクロールモード（qで自動更新に戻る）"; less "$DASHBOARD_FILE"; clear' INT

while true; do
    clear
    echo -e "\033[90m[$(date '+%H:%M:%S')] 自動更新中 | Ctrl+C でスクロールモード\033[0m"
    echo ""
    cat "$DASHBOARD_FILE"
    sleep $INTERVAL
done
