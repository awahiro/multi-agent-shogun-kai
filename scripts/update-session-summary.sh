#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# update-session-summary.sh - セッション要約を更新（トークン節約版）
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法: 
#   ./scripts/update-session-summary.sh [project_name] [phase]
#   ./scripts/update-session-summary.sh --add-decision "決定内容"
#   ./scripts/update-session-summary.sh --add-completed "タスク" "エージェント"
# 
# 将軍が定期的に呼び出してセッション状態を保存。
# コンパクション復帰時に全エージェントがこれを読んで状況把握（30%トークン削減）。
# ═══════════════════════════════════════════════════════════════════════════════

SUMMARY_FILE="memory/session_summary.yaml"
SESSION_NAME=$(cat .session-name 2>/dev/null || echo "unknown")
TIMESTAMP=$(date "+%Y-%m-%dT%H:%M:%S")

# 使い方ヘルプ
show_help() {
    echo "使用法:"
    echo "  $0 [project] [phase]          # 基本更新"
    echo "  $0 --status                   # 現在の状態表示"
}

# ステータス表示
show_status() {
    if [ -f "$SUMMARY_FILE" ]; then
        cat "$SUMMARY_FILE"
    else
        echo "要約ファイルが見つかりません"
    fi
}

# 特殊オプション処理（先に処理）
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --status)
        show_status
        exit 0
        ;;
esac

PROJECT_NAME="${1:-}"
PHASE="${2:-}"

# 現在のアクティブタスク数をカウント
count_active_tasks() {
    local agent_pattern="$1"
    local count=0
    for f in queue/tasks/${agent_pattern}*.yaml; do
        if [ -f "$f" ]; then
            status=$(grep -E "^\s*status:" "$f" 2>/dev/null | head -1 | sed 's/.*status:\s*//' | tr -d ' ')
            if [ "$status" != "idle" ] && [ "$status" != "completed" ] && [ -n "$status" ]; then
                count=$((count + 1))
            fi
        fi
    done
    echo $count
}

# タスク概要を取得
get_task_summary() {
    local agent_pattern="$1"
    for f in queue/tasks/${agent_pattern}*.yaml; do
        if [ -f "$f" ]; then
            status=$(grep -E "^\s*status:" "$f" 2>/dev/null | head -1 | sed 's/.*status:\s*//' | tr -d ' ')
            if [ "$status" != "idle" ] && [ "$status" != "completed" ] && [ -n "$status" ]; then
                desc=$(grep -E "^\s*description:" "$f" 2>/dev/null | head -1 | sed 's/.*description:\s*//')
                echo "    - \"${desc}\""
            fi
        fi
    done
}

# アクティブタスク数
SAMURAI_COUNT=$(count_active_tasks "3_samurai")
ASHIGARU_COUNT=$(count_active_tasks "4_ashigaru")
NINJA_COUNT=$(count_active_tasks "7_ninja")
TOTAL=$((SAMURAI_COUNT + ASHIGARU_COUNT + NINJA_COUNT))

# 要約ファイル更新
cat > "$SUMMARY_FILE" << EOF
# セッション要約（コンパクション復帰用）
# 将軍が更新。全エージェントがコンパクション復帰時に参照。

session:
  started: ""
  last_updated: "${TIMESTAMP}"
  session_name: "${SESSION_NAME}"

current_project:
  name: "${PROJECT_NAME}"
  path: "projects/${PROJECT_NAME}"
  phase: "${PHASE}"

active_tasks:
  total: ${TOTAL}
  samurai:
$(get_task_summary "3_samurai")
  ashigaru:
$(get_task_summary "4_ashigaru")
  ninja:
$(get_task_summary "7_ninja")

recent_completed: []

key_decisions: []

blockers: []

next_actions: []
EOF

echo "セッション要約を更新: ${SUMMARY_FILE}"
