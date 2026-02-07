#!/bin/bash
# 🏯 multi-agent-shogun 出陣スクリプト（毎日の起動用）
# Daily Deployment Script for Multi-Agent Orchestration System
#
# 使用方法:
#   ./start.sh           # 全エージェント起動（通常）
#   ./start.sh -s        # セットアップのみ（Claude起動なし）
#   ./start.sh -h        # ヘルプ表示

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ═══════════════════════════════════════════════════════════════════════════════
# セッション名生成（ディレクトリパスからUUID生成）
# ═══════════════════════════════════════════════════════════════════════════════
SESSION_UUID=$(echo -n "$(pwd)" | md5sum | cut -c1-8 | tr 'a-f' 'A-F')
SESSION_NAME="multiagent-${SESSION_UUID}"

# セッション名をファイルに保存
echo "$SESSION_NAME" > .session-name

# 言語設定を読み取り（デフォルト: ja）
LANG_SETTING="ja"
if [ -f "./config/settings.yaml" ]; then
    LANG_SETTING=$(grep "^language:" ./config/settings.yaml 2>/dev/null | awk '{print $2}' || echo "ja")
fi

# シェル設定を読み取り（デフォルト: bash）
SHELL_SETTING="bash"
if [ -f "./config/settings.yaml" ]; then
    SHELL_SETTING=$(grep "^shell:" ./config/settings.yaml 2>/dev/null | awk '{print $2}' || echo "bash")
fi

# 色付きログ関数（戦国風）
log_info() {
    echo -e "\033[1;33m【報】\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m【成】\033[0m $1"
}

log_war() {
    echo -e "\033[1;31m【戦】\033[0m $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# プロンプト生成関数（bash/zsh対応）
# ───────────────────────────────────────────────────────────────────────────────
# 使用法: generate_prompt "ラベル" "色" "シェル"
# 色: red, green, blue, magenta, cyan, yellow
# ═══════════════════════════════════════════════════════════════════════════════
generate_prompt() {
    local label="$1"
    local color="$2"
    local shell_type="$3"

    if [ "$shell_type" == "zsh" ]; then
        # zsh用: %F{color}%B...%b%f 形式
        echo "(%F{${color}}%B${label}%b%f) %F{green}%B%~%b%f%# "
    else
        # bash用: \[\033[...m\] 形式
        local color_code
        case "$color" in
            red)     color_code="1;31" ;;
            green)   color_code="1;32" ;;
            yellow)  color_code="1;33" ;;
            blue)    color_code="1;34" ;;
            magenta) color_code="1;35" ;;
            cyan)    color_code="1;36" ;;
            *)       color_code="1;37" ;;  # white (default)
        esac
        echo "(\[\033[${color_code}m\]${label}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ "
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
SETUP_ONLY=false
OPEN_TERMINAL=false
SHELL_OVERRIDE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--setup-only)
            SETUP_ONLY=true
            shift
            ;;
        -t|--terminal)
            OPEN_TERMINAL=true
            shift
            ;;
        -shell|--shell)
            if [[ -n "$2" && "$2" != -* ]]; then
                SHELL_OVERRIDE="$2"
                shift 2
            else
                echo "エラー: -shell オプションには bash または zsh を指定してください"
                exit 1
            fi
            ;;
        -h|--help)
            echo ""
            echo "🏯 multi-agent-shogun 出陣スクリプト"
            echo ""
            echo "使用方法: ./start.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -s, --setup-only    tmuxセッションのセットアップのみ（Claude起動なし）"
            echo "  -t, --terminal      Windows Terminal で新しいタブを開く"
            echo "  -shell, --shell SH  シェルを指定（bash または zsh）"
            echo "                      未指定時は config/settings.yaml の設定を使用"
            echo "  -h, --help          このヘルプを表示"
            echo ""
            echo "例:"
            echo "  ./start.sh              # 全エージェント起動（通常の出陣）"
            echo "  ./start.sh -s           # セットアップのみ（手動でClaude起動）"
            echo "  ./start.sh -t           # 全エージェント起動 + ターミナルタブ展開"
            echo "  ./start.sh -shell bash  # bash用プロンプトで起動"
            echo "  ./start.sh -shell zsh   # zsh用プロンプトで起動"
            echo ""
            echo "エイリアス:"
            echo "  csst  → cd /mnt/c/tools/multi-agent-shogun && ./start.sh"
            echo "  css   → tmux attach-session -t $SESSION_NAME"
            echo "  csm   → tmux attach-session -t $SESSION_NAME"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./start.sh -h でヘルプを表示"
            exit 1
            ;;
    esac
done

# シェル設定のオーバーライド（コマンドラインオプション優先）
if [ -n "$SHELL_OVERRIDE" ]; then
    if [[ "$SHELL_OVERRIDE" == "bash" || "$SHELL_OVERRIDE" == "zsh" ]]; then
        SHELL_SETTING="$SHELL_OVERRIDE"
    else
        echo "エラー: -shell オプションには bash または zsh を指定してください（指定値: $SHELL_OVERRIDE）"
        exit 1
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 出陣バナー表示（CC0ライセンスASCIIアート使用）
# ───────────────────────────────────────────────────────────────────────────────
# 【著作権・ライセンス表示】
# 忍者ASCIIアート: syntax-samurai/ryu - CC0 1.0 Universal (Public Domain)
# 出典: https://github.com/syntax-samurai/ryu
# "all files and scripts in this repo are released CC0 / kopimi!"
# ═══════════════════════════════════════════════════════════════════════════════
show_battle_cry() {
    clear

    # タイトルバナー（色付き）
    echo ""
    echo -e "\033[1;31m╔══════════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m███████╗██╗  ██╗██╗   ██╗████████╗███████╗██╗   ██╗     ██╗██╗███╗   ██╗\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m██╔════╝██║  ██║██║   ██║╚══██╔══╝██╔════╝██║   ██║     ██║██║████╗  ██║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m███████╗███████║██║   ██║   ██║   ███████╗██║   ██║     ██║██║██╔██╗ ██║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m╚════██║██╔══██║██║   ██║   ██║   ╚════██║██║   ██║██   ██║██║██║╚██╗██║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m███████║██║  ██║╚██████╔╝   ██║   ███████║╚██████╔╝╚█████╔╝██║██║ ╚████║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝  ╚════╝ ╚═╝╚═╝  ╚═══╝\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m╠══════════════════════════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;31m║\033[0m       \033[1;37m出陣じゃーーー！！！\033[0m    \033[1;36m⚔\033[0m    \033[1;35m天下布武！\033[0m                          \033[1;31m║\033[0m"
    echo -e "\033[1;31m╚══════════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # 足軽隊列（オリジナル）
    # ═══════════════════════════════════════════════════════════════════════════
    echo -e "\033[1;34m  ╔═════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;34m  ║\033[0m                  \033[1;37m【 全 軍 配 備 ・ 侍×3 + 足軽×2 + 忍者 】\033[0m                  \033[1;34m║\033[0m"
    echo -e "\033[1;34m  ╚═════════════════════════════════════════════════════════════════════════════╝\033[0m"

    cat << 'ASHIGARU_EOF'

      ⚔️      ⚔️      ⚔️      👤      👤      🥷
     /||\    /||\    /||\    /||\    /||\    /||\
    /_||\   /_||\   /_||\   /_||\   /_||\   /_||\
      ||      ||      ||      ||      ||      ||
     /||\    /||\    /||\    /||\    /||\    /||\
     /  \    /  \    /  \    /  \    /  \    /  \
    [侍1]   [侍2]   [侍3]   [足1]   [足2]   [忍者]

ASHIGARU_EOF

    echo -e "                    \033[1;36m「「「 はっ！！ 出陣いたす！！ 」」」\033[0m"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # システム情報
    # ═══════════════════════════════════════════════════════════════════════════
    echo -e "\033[1;33m  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\033[0m"
    echo -e "\033[1;33m  ┃\033[0m  \033[1;37m🏯 multi-agent-shogun\033[0m  〜 \033[1;36m戦国マルチエージェント統率システム\033[0m 〜           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m                                                                           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m  \033[1;35m将軍\033[0m: 統括+管理  \033[1;34m侍×3\033[0m: 実装  \033[1;36m足軽×2\033[0m: 補助  \033[1;32m忍者\033[0m: 緊急     \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m"
    echo ""
}

# バナー表示実行
show_battle_cry

echo -e "  \033[1;33m天下布武！陣立てを開始いたす\033[0m (Setting up the battlefield)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: 既存セッションクリーンアップ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🧹 既存の陣を撤収中..."
# 旧shogunセッションがあれば削除（後方互換）
tmux kill-session -t $SESSION_NAME 2>/dev/null && log_info "  └─ ${SESSION_NAME}本陣、撤収完了" || log_info "  └─ ${SESSION_NAME}本陣は存在せず"

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1.5: 前回記録のバックアップ（内容がある場合のみ）
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📦 前回の記録をバックアップ中..."
./scripts/backup.sh -q || true

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: タスク・報告ファイル初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📋 タスク・報告ファイルを初期化中..."
./scripts/task_init.sh -q
log_success "  └─ タスク・報告ファイル初期化完了"

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: エージェント初期化状態のリセット
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🔄 エージェント初期化状態をリセット中..."

# status ディレクトリが存在しない場合は作成
[ -d ./status ] || mkdir -p ./status

# 各エージェントごとの初期化状態ファイルを作成（競合回避）
for agent in samurai1 samurai2 samurai3 ashigaru1 ashigaru2 ninja; do
    cat > "./status/${agent}.yaml" << EOF
# ${agent}の初期化状態
initialized: false
last_updated: ""
EOF
done

log_success "  └─ エージェント初期化状態リセット完了（全エージェント未初期化）"

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: ダッシュボード初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📊 戦況報告板を初期化中..."
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

if [ "$LANG_SETTING" = "ja" ]; then
    # 日本語のみ
    cat > ./dashboard.md << EOF
# 📊 戦況報告
最終更新: ${TIMESTAMP}

## 🚨 要対応 - 殿のご判断をお待ちしております
なし

## 🔄 進行中 - 只今、戦闘中でござる
なし

## ✅ 本日の戦果
| 時刻 | 戦場 | 任務 | 結果 |
|------|------|------|------|

## 🎯 スキル化候補 - 承認待ち
なし

## 🛠️ 生成されたスキル
なし

## ⏸️ 待機中
なし

## ❓ 伺い事項
なし
EOF
else
    # 日本語 + 翻訳併記
    cat > ./dashboard.md << EOF
# 📊 戦況報告 (Battle Status Report)
最終更新 (Last Updated): ${TIMESTAMP}

## 🚨 要対応 - 殿のご判断をお待ちしております (Action Required - Awaiting Lord's Decision)
なし (None)

## 🔄 進行中 - 只今、戦闘中でござる (In Progress - Currently in Battle)
なし (None)

## ✅ 本日の戦果 (Today's Achievements)
| 時刻 (Time) | 戦場 (Battlefield) | 任務 (Mission) | 結果 (Result) |
|------|------|------|------|

## 🎯 スキル化候補 - 承認待ち (Skill Candidates - Pending Approval)
なし (None)

## 🛠️ 生成されたスキル (Generated Skills)
なし (None)

## ⏸️ 待機中 (On Standby)
なし (None)

## ❓ 伺い事項 (Questions for Lord)
なし (None)
EOF
fi

log_success "  └─ ダッシュボード初期化完了 (言語: $LANG_SETTING, シェル: $SHELL_SETTING)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: shogunセッション作成（7ペイン統合：将軍 + samurai1-3 + ashigaru1-2 + ninja）
# ═══════════════════════════════════════════════════════════════════════════════
# tmux の存在確認
if ! command -v tmux &> /dev/null; then
    echo ""
    echo "  ╔════════════════════════════════════════════════════════╗"
    echo "  ║  [ERROR] tmux not found!                              ║"
    echo "  ║  tmux が見つかりません                                 ║"
    echo "  ╠════════════════════════════════════════════════════════╣"
    echo "  ║  Run first_setup.sh first:                            ║"
    echo "  ║  まず first_setup.sh を実行してください:               ║"
    echo "  ║     ./first_setup.sh                                  ║"
    echo "  ╚════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

log_war "🏯 全軍の陣を構築中（将軍 + 実働部隊6名）..."

# セッション作成
if ! tmux new-session -d -s $SESSION_NAME -n "battlefield" 2>/dev/null; then
    echo ""
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║  [ERROR] Failed to create tmux session                   ║"
    echo "  ║  tmux セッション '${SESSION_NAME}' の作成に失敗         ║"
    echo "  ╠════════════════════════════════════════════════════════════╣"
    echo "  ║  An existing session may be running.                     ║"
    echo "  ║  既存セッションが残っている可能性があります              ║"
    echo "  ║                                                          ║"
    echo "  ║  Check: tmux ls                                          ║"
    echo "  ║  Kill:  tmux kill-session -t $SESSION_NAME               ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

# ペインボーダーにタイトルを表示する設定
tmux set-option -g pane-border-status top
# ペイン番号に基づく固定ラベル表示（Claude Codeによる上書きを回避）
tmux set-option -g pane-border-format '#{pane_index}: #{?#{==:#{pane_index},0},dashboard,#{?#{==:#{pane_index},1},将軍,#{?#{==:#{pane_index},2},侍1,#{?#{==:#{pane_index},3},足軽1,#{?#{==:#{pane_index},4},侍2,#{?#{==:#{pane_index},5},足軽2,#{?#{==:#{pane_index},6},侍3,#{?#{==:#{pane_index},7},忍者,?}}}}}}}}'

# 8ペインレイアウト作成（dashboard含む）
# +------------+------------+----------+----------+----------+
# | dashboard  |   将軍     |   侍1    |   侍2    |   侍3    |
# |   (0)      |   (1)      |   (2)    |   (4)    |   (6)    |
# |   20%      |   20%      +----------+----------+----------+
# |            |            |  足軽1   |  足軽2   |  忍者    |
# |            |            |   (3)    |   (5)    |   (7)    |
# +------------+------------+----------+----------+----------+

# Step 1: 5列均等に分割（各20%）
tmux split-window -h -t "${SESSION_NAME}:0" -p 80    # dash 20% | 残り 80%
tmux split-window -h -t "${SESSION_NAME}:0.1" -p 75  # 将軍 20% | 残り 60%
tmux split-window -h -t "${SESSION_NAME}:0.2" -p 67  # 列3 20% | 残り 40%
tmux split-window -h -t "${SESSION_NAME}:0.3" -p 50  # 列4 20% | 列5 20%
# 現在: 0=dashboard, 1=将軍, 2=列3, 3=列4, 4=列5

# Step 2: 右3列（pane 2,3,4）を上下分割
tmux split-window -v -t "${SESSION_NAME}:0.2" -p 50  # 列3 → 侍1(2) | 足軽1(3)
# 現在: 0=dashboard, 1=将軍, 2=侍1, 3=足軽1, 4=列4, 5=列5
tmux split-window -v -t "${SESSION_NAME}:0.4" -p 50  # 列4 → 侍2(4) | 足軽2(5)
# 現在: 0=dashboard, 1=将軍, 2=侍1, 3=足軽1, 4=侍2, 5=足軽2, 6=列5
tmux split-window -v -t "${SESSION_NAME}:0.6" -p 50  # 列5 → 侍3(6) | 忍者(7)
# 最終: 0=dashboard, 1=将軍, 2=侍1, 3=足軽1, 4=侍2, 5=足軽2, 6=侍3, 7=忍者

# ペインタイトルと環境変数設定（8ペイン体制）
# 0: dashboard, 1: 将軍, 2: 侍1, 3: 足軽1, 4: 侍2, 5: 足軽2, 6: 侍3, 7: 忍者
PANE_TITLES=("dashboard" "将軍" "侍1" "足軽1" "侍2" "足軽2" "侍3" "忍者")
PANE_LABELS=("dashboard" "将軍" "samurai1" "ashigaru1" "samurai2" "ashigaru2" "samurai3" "ninja")
# 色設定（dashboard: 白, 将軍: 紫, 侍: 青, 足軽: 黄, 忍者: 紫）
PANE_COLORS=("white" "magenta" "blue" "yellow" "blue" "yellow" "blue" "magenta")

# dashboardペイン（pane 0）の設定
# Ctrl+C でスクロールモード（less）、qで自動更新に戻る
tmux select-pane -t "${SESSION_NAME}:0.0" -T "dashboard"
tmux send-keys -t "${SESSION_NAME}:0.0" "$(pwd)/scripts/dashboard-view.sh $(pwd)/dashboard.md" Enter

# エージェントペイン（pane 1-7）の設定
for i in {1..7}; do
    tmux select-pane -t "${SESSION_NAME}:0.$i" -T "${PANE_TITLES[$i]}"
    PROMPT_STR=$(generate_prompt "${PANE_LABELS[$i]}" "${PANE_COLORS[$i]}" "$SHELL_SETTING")
    tmux send-keys -t "${SESSION_NAME}:0.$i" "cd \"$(pwd)\" && export PS1='${PROMPT_STR}' && export AGENT_ROLE='${PANE_TITLES[$i]}' && export AGENT_PANE='${SESSION_NAME}:0.$i' && clear" Enter
done

# 将軍ペインに背景色を設定
tmux select-pane -t "${SESSION_NAME}:0.1" -P 'bg=#002b36'

log_success "  └─ 全軍の陣、構築完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6: Claude Code 起動（--setup-only でスキップ）
# ═══════════════════════════════════════════════════════════════════════════════
if [ "$SETUP_ONLY" = false ]; then
    # Claude Code CLI の存在チェック
    if ! command -v claude &> /dev/null; then
        log_info "⚠️  claude コマンドが見つかりません"
        echo "  first_setup.sh を再実行してください:"
        echo "    ./first_setup.sh"
        exit 1
    fi

    log_war "👑 全軍に Claude Code を召喚中..."

    # 将軍（pane 1）
    tmux send-keys -t "${SESSION_NAME}:0.1" "MAX_THINKING_TOKENS=0 claude --model opus --dangerously-skip-permissions"
    tmux send-keys -t "${SESSION_NAME}:0.1" Enter
    log_info "  └─ 将軍、召喚完了"

    # 少し待機（安定のため）
    sleep 1

    # 新ペイン番号: 2=侍1, 3=足軽1, 4=侍2, 5=足軽2, 6=侍3, 7=忍者
    # 侍1-3（sonnet）- pane 2, 4, 6
    for i in 2 4 6; do
        tmux send-keys -t "${SESSION_NAME}:0.$i" "claude --model sonnet --dangerously-skip-permissions"
        tmux send-keys -t "${SESSION_NAME}:0.$i" Enter
    done
    log_info "  └─ 侍×3（sonnet）召喚完了"

    # 足軽1-2（haiku）- pane 3, 5
    for i in 3 5; do
        tmux send-keys -t "${SESSION_NAME}:0.$i" "claude --model haiku --dangerously-skip-permissions"
        tmux send-keys -t "${SESSION_NAME}:0.$i" Enter
    done
    log_info "  └─ 足軽×2（haiku）召喚完了"

    # 忍者（opus）- pane 7
    tmux send-keys -t "${SESSION_NAME}:0.7" "MAX_THINKING_TOKENS=0 claude --model opus --dangerously-skip-permissions"
    tmux send-keys -t "${SESSION_NAME}:0.7" Enter
    log_info "  └─ 忍者（opus）召喚完了"

    log_success "✅ 全軍 Claude Code 起動完了"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 6.5: 起動確認のみ（指示書は初回タスク時に読む）
    # ═══════════════════════════════════════════════════════════════════════════
    log_war "⏳ Claude Code 起動確認中（最大30秒）..."


    # 将軍の起動を確認（最大30秒待機）
    for i in {1..30}; do
        if tmux capture-pane -t "${SESSION_NAME}:0.1" -p | grep -q "bypass permissions"; then
            echo "  └─ 将軍の Claude Code 起動確認完了（${i}秒）"
            break
        fi
        echo -n "."
        sleep 1
    done

    echo ""

    log_war "⏳ 将軍が指示書を読み込み中..."
    # 将軍に指示書を読み込ませる
    log_info "  └─ 将軍に指示書を伝達中..."
    tmux send-keys -t "${SESSION_NAME}:0.1" "instructions/1_shogun.md を読んで役割を理解せよ。"
    sleep 0.5
    tmux send-keys -t "${SESSION_NAME}:0.1" Enter

    # 起動確認メッセージのみ（指示書は読まない）
    log_success "✅ 全軍 Claude Code 起動確認完了"
    echo ""
    log_info "📌 各エージェントは初回指示時に自動的に指示書を読み込みます"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 6.6: 報告ファイル監視を起動（バックグラウンド）
    # ═══════════════════════════════════════════════════════════════════════════
    log_info "📡 報告ファイル監視を起動中..."

    # 既存の監視プロセスを停止
    ./scripts/report_watcher.sh --stop 2>/dev/null || true

    # バックグラウンドで起動
    nohup ./scripts/report_watcher.sh > /dev/null 2>&1 &

    sleep 1
    if [ -f ".report_watcher.pid" ]; then
        WATCHER_PID=$(cat .report_watcher.pid)
        log_success "  └─ 報告ファイル監視起動完了 (PID: $WATCHER_PID)"
    else
        log_info "  └─ 報告ファイル監視の起動を確認できませんでした"
    fi
    echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7: 環境確認・完了メッセージ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🔍 陣容を確認中..."
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📺 Tmux陣容 (Sessions)                                  │"
echo "  └──────────────────────────────────────────────────────────┘"
tmux list-sessions | sed 's/^/     /'
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📋 布陣図 (Formation)                                   │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "     【${SESSION_NAME}セッション】全軍統合（7ペイン）"
echo "     ┌─────────────────────────────────────────┐"
echo "     │         Pane 0: 将軍 (SHOGUN)          │"
echo "     ├─────────────┬─────────────┬────────────┤"
echo "     │ Pane 1: 侍1 │ Pane 2: 侍2 │ Pane 3: 侍3│"
echo "     ├─────────────┼─────────────┼────────────┤"
echo "     │ Pane 4: 足1 │ Pane 5: 足2 │ Pane 6: 忍 │"
echo "     └─────────────┴─────────────┴────────────┘"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  🏯 出陣準備完了！天下布武！                              ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""

if [ "$SETUP_ONLY" = true ]; then
    echo "  ⚠️  セットアップのみモード: Claude Codeは未起動です"
    echo ""
    echo "  手動でClaude Codeを起動するには:"
    echo "  ┌──────────────────────────────────────────────────────────┐"
    echo "  │  # 全軍を一斉召喚                                         │"
    echo "  │  for i in {0..6}; do \\                                   │"
    echo "  │    tmux send-keys -t ${SESSION_NAME}:0.\$i \\                       │"
    echo "  │      'claude --dangerously-skip-permissions' Enter       │"
    echo "  │  done                                                    │"
    echo "  └──────────────────────────────────────────────────────────┘"
    echo ""
fi

echo "  次のステップ:"
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  全軍にアタッチして命令を開始:                            │"
echo "  │     tmux attach-session -t $SESSION_NAME   (または: css)        │"
echo "  │                                                          │"
echo "  │  ペイン切り替え: Ctrl+B → 矢印キー                       │"
echo "  │                                                          │"
echo "  │  ※ 各エージェントは初回指示時に自動的に指示書を         │"
echo "  │    読み込みます（コスト節約）。                          │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "  ════════════════════════════════════════════════════════════"
echo "   天下布武！勝利を掴め！ (Tenka Fubu! Seize victory!)"
echo "  ════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 8: Windows Terminal でタブを開く（-t オプション時のみ）
# ═══════════════════════════════════════════════════════════════════════════════
if [ "$OPEN_TERMINAL" = true ]; then
    log_info "📺 Windows Terminal でタブを展開中..."

    # Windows Terminal が利用可能か確認
    if command -v wt.exe &> /dev/null; then
        wt.exe -w 0 new-tab wsl.exe -e bash -c "tmux attach-session -t $SESSION_NAME"
        log_success "  └─ ターミナルタブ展開完了"
    else
        log_info "  └─ wt.exe が見つかりません。手動でアタッチしてください。"
    fi
    echo ""
fi
