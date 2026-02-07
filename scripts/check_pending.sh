#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# check_pending.sh - 未報告エージェント検出スクリプト
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/check_pending.sh           # 未報告エージェントを表示
#   ./scripts/check_pending.sh --remind  # 未報告エージェントにリマインダー送信
#   ./scripts/check_pending.sh -h        # ヘルプ表示
#
# 機能:
#   - タスクが割り当てられているが報告がないエージェントを検出
#   - --remind オプションでリマインダーを送信
# ═══════════════════════════════════════════════════════════════════════════════

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# オプション
REMIND_MODE=false
QUIET_MODE=false

# ヘルプ表示
show_help() {
    echo ""
    echo "📋 check_pending.sh - 未報告エージェント検出"
    echo ""
    echo "使用法:"
    echo "  ./scripts/check_pending.sh           # 未報告エージェントを表示"
    echo "  ./scripts/check_pending.sh --remind  # リマインダーを送信"
    echo "  ./scripts/check_pending.sh -q        # 静かモード（戻り値のみ）"
    echo "  ./scripts/check_pending.sh -h        # このヘルプを表示"
    echo ""
    echo "戻り値:"
    echo "  0: 未報告エージェントなし"
    echo "  1: 未報告エージェントあり"
    echo ""
    exit 0
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        --remind)
            REMIND_MODE=true
            shift
            ;;
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./scripts/check_pending.sh -h でヘルプを表示"
            exit 2
            ;;
    esac
done

# セッション名を取得
get_session_name() {
    if [ -f ".session-name" ]; then
        cat .session-name
    else
        echo ""
    fi
}

# エージェント名からペイン番号を取得
get_pane_number() {
    local agent="$1"
    case "$agent" in
        samurai1)  echo "0.2" ;;
        samurai2)  echo "0.4" ;;
        samurai3)  echo "0.6" ;;
        ashigaru1) echo "0.3" ;;
        ashigaru2) echo "0.5" ;;
        ninja)     echo "0.7" ;;
        *)         echo "" ;;
    esac
}

# エージェント名を日本語に変換
get_agent_display_name() {
    local agent="$1"
    case "$agent" in
        samurai1)  echo "侍1" ;;
        samurai2)  echo "侍2" ;;
        samurai3)  echo "侍3" ;;
        ashigaru1) echo "足軽1" ;;
        ashigaru2) echo "足軽2" ;;
        ninja)     echo "忍者" ;;
        *)         echo "$agent" ;;
    esac
}

# 未報告エージェントを検出
detect_pending() {
    local pending_agents=()
    local pending_tasks=()
    local pending_timestamps=()

    # 侍のチェック
    for i in 1 2 3; do
        local task_file="queue/tasks/3_samurai${i}.yaml"
        local report_file="queue/reports/3_samurai${i}_report.yaml"

        if [ -f "$task_file" ]; then
            # タスクが割り当てられているか確認
            local task_id
            task_id=$(grep "task_id:" "$task_file" 2>/dev/null | head -1 | sed 's/.*task_id: *//' | tr -d '"')

            if [ -n "$task_id" ] && [ "$task_id" != "null" ]; then
                # 報告ファイルの状態を確認
                local report_status="idle"
                if [ -f "$report_file" ]; then
                    report_status=$(grep "^status:" "$report_file" 2>/dev/null | head -1 | sed 's/.*status: *//' | tr -d '"')
                fi

                if [ "$report_status" != "completed" ]; then
                    pending_agents+=("samurai${i}")
                    local desc
                    desc=$(grep "description:" "$task_file" 2>/dev/null | head -1 | sed 's/.*description: *//' | tr -d '"')
                    pending_tasks+=("$desc")
                    local ts
                    ts=$(grep "timestamp:" "$task_file" 2>/dev/null | head -1 | sed 's/.*timestamp: *//' | tr -d '"')
                    pending_timestamps+=("$ts")
                fi
            fi
        fi
    done

    # 足軽のチェック
    for i in 1 2; do
        local task_file="queue/tasks/4_ashigaru${i}.yaml"
        local report_file="queue/reports/4_ashigaru${i}_report.yaml"

        if [ -f "$task_file" ]; then
            local task_id
            task_id=$(grep "task_id:" "$task_file" 2>/dev/null | head -1 | sed 's/.*task_id: *//' | tr -d '"')

            if [ -n "$task_id" ] && [ "$task_id" != "null" ]; then
                local report_status="idle"
                if [ -f "$report_file" ]; then
                    report_status=$(grep "^status:" "$report_file" 2>/dev/null | head -1 | sed 's/.*status: *//' | tr -d '"')
                fi

                if [ "$report_status" != "completed" ]; then
                    pending_agents+=("ashigaru${i}")
                    local desc
                    desc=$(grep "description:" "$task_file" 2>/dev/null | head -1 | sed 's/.*description: *//' | tr -d '"')
                    pending_tasks+=("$desc")
                    local ts
                    ts=$(grep "timestamp:" "$task_file" 2>/dev/null | head -1 | sed 's/.*timestamp: *//' | tr -d '"')
                    pending_timestamps+=("$ts")
                fi
            fi
        fi
    done

    # 忍者のチェック
    local task_file="queue/tasks/7_ninja.yaml"
    local report_file="queue/reports/7_ninja_report.yaml"

    if [ -f "$task_file" ]; then
        local task_id
        task_id=$(grep "task_id:" "$task_file" 2>/dev/null | head -1 | sed 's/.*task_id: *//' | tr -d '"')

        if [ -n "$task_id" ] && [ "$task_id" != "null" ]; then
            local report_status="idle"
            if [ -f "$report_file" ]; then
                report_status=$(grep "^status:" "$report_file" 2>/dev/null | head -1 | sed 's/.*status: *//' | tr -d '"')
            fi

            if [ "$report_status" != "completed" ]; then
                pending_agents+=("ninja")
                local desc
                desc=$(grep "description:" "$task_file" 2>/dev/null | head -1 | sed 's/.*description: *//' | tr -d '"')
                pending_tasks+=("$desc")
                local ts
                ts=$(grep "timestamp:" "$task_file" 2>/dev/null | head -1 | sed 's/.*timestamp: *//' | tr -d '"')
                pending_timestamps+=("$ts")
            fi
        fi
    fi

    # 結果を出力
    local count=${#pending_agents[@]}

    if [ "$count" -eq 0 ]; then
        if [ "$QUIET_MODE" = false ]; then
            echo "【成】全エージェントの報告が完了しています"
        fi
        return 0
    fi

    if [ "$QUIET_MODE" = false ]; then
        echo "【報】未報告エージェントを検出中..."
        echo ""
        for i in "${!pending_agents[@]}"; do
            local agent="${pending_agents[$i]}"
            local display_name
            display_name=$(get_agent_display_name "$agent")
            local task="${pending_tasks[$i]}"
            local ts="${pending_timestamps[$i]}"

            echo "  ⚠ ${display_name}: タスク割当済み ($ts) だが報告なし"
            if [ -n "$task" ]; then
                echo "    └─ タスク: ${task:0:50}"
            fi
        done
        echo ""
    fi

    # リマインダー送信
    if [ "$REMIND_MODE" = true ]; then
        local session_name
        session_name=$(get_session_name)

        if [ -z "$session_name" ]; then
            echo "【エラー】セッション名が取得できません"
            return 1
        fi

        echo "【報】リマインダーを送信中..."
        for agent in "${pending_agents[@]}"; do
            local pane_num
            pane_num=$(get_pane_number "$agent")
            local display_name
            display_name=$(get_agent_display_name "$agent")

            if [ -n "$pane_num" ]; then
                ./scripts/notify.sh "${session_name}:${pane_num}" "将軍" "報告を忘れておらぬか？速やかに報告せよ。"
                echo "  └─ リマインダー送信: ${display_name} (pane ${pane_num})"
                sleep 0.5
            fi
        done
        echo ""
        echo "【成】リマインダー送信完了"
    else
        if [ "$QUIET_MODE" = false ]; then
            echo "💡 リマインダーを送信するには: ./scripts/check_pending.sh --remind"
        fi
    fi

    return 1
}

# 実行
detect_pending
