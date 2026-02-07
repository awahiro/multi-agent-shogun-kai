#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# compact.sh - エージェントに /compact コマンドを送信
# ═══════════════════════════════════════════════════════════════════════════════
# 使用法:
#   ./scripts/compact.sh <pane>           # 指定ペインに /compact 送信
#   ./scripts/compact.sh -a <panes...>    # 複数ペインに順次送信
#   ./scripts/compact.sh --auto           # タスクを実行したエージェントを自動検出して送信
#   ./scripts/compact.sh -h               # ヘルプ表示
#
# 例:
#   SESSION_NAME=$(cat .session-name)
#   ./scripts/compact.sh ${SESSION_NAME}:0.2              # 侍1のみ
#   ./scripts/compact.sh -a ${SESSION_NAME}:0.2 ${SESSION_NAME}:0.1  # 侍1 → 将軍
#   ./scripts/compact.sh --auto           # 自動検出（タスク実行エージェント + 将軍）
#
# 注意:
#   - エージェントがプロンプト待ち状態でないと実行されない
#   - 将軍自身への送信は最後に行うこと（処理が中断するため）
#   - --auto は task_init.sh 実行前に使用すること（タスクファイルが必要）
# ═══════════════════════════════════════════════════════════════════════════════

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# ヘルプ表示
show_help() {
    echo ""
    echo "📦 compact.sh - エージェントに /compact コマンドを送信"
    echo ""
    echo "使用法:"
    echo "  ./scripts/compact.sh <pane>           # 指定ペインに /compact 送信"
    echo "  ./scripts/compact.sh -a <panes...>    # 複数ペインに順次送信"
    echo "  ./scripts/compact.sh --auto           # タスクを実行したエージェントを自動検出"
    echo "  ./scripts/compact.sh -h               # このヘルプを表示"
    echo ""
    echo "例:"
    echo "  SESSION_NAME=\$(cat .session-name)"
    echo "  ./scripts/compact.sh \${SESSION_NAME}:0.2              # 侍1のみ"
    echo "  ./scripts/compact.sh -a \${SESSION_NAME}:0.2 \${SESSION_NAME}:0.1  # 侍1 → 将軍"
    echo "  ./scripts/compact.sh --auto           # 自動検出（推奨）"
    echo ""
    echo "ペイン番号:"
    echo "  0.1 = 将軍"
    echo "  0.2 = 侍1, 0.4 = 侍2, 0.6 = 侍3"
    echo "  0.3 = 足軽1, 0.5 = 足軽2"
    echo "  0.7 = 忍者"
    echo ""
    echo "注意:"
    echo "  - エージェントがプロンプト待ち状態でないと実行されない"
    echo "  - 将軍自身への送信は最後に行うこと（処理が中断するため）"
    echo "  - --auto は task_init.sh 実行前に使用すること"
    echo ""
    exit 0
}

# /compact を送信する関数
send_compact() {
    local pane="$1"
    local agent_name="$2"
    tmux send-keys -t "$pane" "/compact"
    tmux send-keys -t "$pane" Enter
    if [ -n "$agent_name" ]; then
        echo "  └─ /compact 送信: $agent_name ($pane)"
    else
        echo "  └─ /compact 送信: $pane"
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
        shogun)    echo "0.1" ;;
        *)         echo "" ;;
    esac
}

# タスクファイルからタスクが割り当てられたエージェントを検出
detect_assigned_agents() {
    local agents=()

    # 侍のタスクファイルをチェック
    for i in 1 2 3; do
        local file="queue/tasks/3_samurai${i}.yaml"
        if [ -f "$file" ]; then
            # task_id が null でないかチェック
            if grep -q "task_id:" "$file" && ! grep -q "task_id: null" "$file"; then
                agents+=("samurai${i}")
            fi
        fi
    done

    # 足軽のタスクファイルをチェック
    for i in 1 2; do
        local file="queue/tasks/4_ashigaru${i}.yaml"
        if [ -f "$file" ]; then
            if grep -q "task_id:" "$file" && ! grep -q "task_id: null" "$file"; then
                agents+=("ashigaru${i}")
            fi
        fi
    done

    # 忍者のタスクファイルをチェック
    local ninja_file="queue/tasks/7_ninja.yaml"
    if [ -f "$ninja_file" ]; then
        if grep -q "task_id:" "$ninja_file" && ! grep -q "task_id: null" "$ninja_file"; then
            agents+=("ninja")
        fi
    fi

    echo "${agents[@]}"
}

# 自動検出モード
auto_compact() {
    local session_name
    if [ -f ".session-name" ]; then
        session_name=$(cat .session-name)
    else
        echo "エラー: .session-name ファイルが見つかりません"
        exit 1
    fi

    echo "【報】タスクを実行したエージェントを検出中..."

    # タスクが割り当てられたエージェントを検出
    local agents
    agents=$(detect_assigned_agents)

    if [ -z "$agents" ]; then
        echo "  └─ タスクを実行したエージェントが見つかりません"
        echo "【報】将軍のみ /compact を実行..."
        send_compact "${session_name}:0.1" "将軍"
        echo "【成】/compact 送信完了"
        return
    fi

    echo "  └─ 検出: $agents"
    echo "【報】エージェント → 将軍 の順で /compact を送信中..."

    # エージェントに /compact 送信
    for agent in $agents; do
        local pane_num
        pane_num=$(get_pane_number "$agent")
        if [ -n "$pane_num" ]; then
            send_compact "${session_name}:${pane_num}" "$agent"
            sleep 0.5
        fi
    done

    # 最後に将軍に /compact 送信
    send_compact "${session_name}:0.1" "将軍"

    echo "【成】/compact 送信完了"
}

# 引数チェック
if [ $# -lt 1 ]; then
    echo "エラー: オプションを指定してください"
    echo "./scripts/compact.sh -h でヘルプを表示"
    exit 1
fi

# オプション解析
case "$1" in
    -h|--help)
        show_help
        ;;
    --auto)
        auto_compact
        ;;
    -a|--all)
        shift
        if [ $# -lt 1 ]; then
            echo "エラー: -a オプションにはペインを指定してください"
            exit 1
        fi
        echo "【報】複数ペインに /compact を送信中..."
        for pane in "$@"; do
            send_compact "$pane"
            sleep 0.5
        done
        echo "【成】/compact 送信完了"
        ;;
    *)
        # 単一ペインへの送信
        send_compact "$1"
        ;;
esac
