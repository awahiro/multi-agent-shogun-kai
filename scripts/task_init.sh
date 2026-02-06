#!/bin/bash
# 📋 multi-agent-shogun タスク初期化スクリプト
# Task Initialization Script for Multi-Agent Orchestration System
#
# 使用方法:
#   ./scripts/task_init.sh           # タスク・報告ファイルを初期化
#   ./scripts/task_init.sh -h        # ヘルプ表示
#
# 戻り値:
#   0: 初期化成功
#   2: エラー

set -e

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
QUIET_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        -h|--help)
            echo ""
            echo "📋 multi-agent-shogun タスク初期化スクリプト"
            echo ""
            echo "使用方法: ./scripts/task_init.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -q, --quiet      静かモード（メッセージを抑制）"
            echo "  -h, --help       このヘルプを表示"
            echo ""
            echo "初期化対象:"
            echo "  - queue/tasks/*.yaml（タスクファイル）"
            echo "  - queue/reports/*.yaml（報告ファイル）"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./scripts/task_init.sh -h でヘルプを表示"
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
# タスク・報告ファイル初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📜 タスク・報告ファイルを初期化中..."

# queue ディレクトリが存在しない場合は作成
[ -d ./queue/reports ] || mkdir -p ./queue/reports
[ -d ./queue/tasks ] || mkdir -p ./queue/tasks

# 忍者タスクファイル作成（opus）
cat > ./queue/tasks/7_ninja.yaml << EOF
# 忍者専用タスクファイル [opus]
task:
  task_id: null
  parent_cmd: null
  description: null
  classification: null  # top_secret/classified/normal
  status: idle
  timestamp: ""
EOF

# 侍タスクファイルリセット（sonnet × 3）
for i in {1..3}; do
    cat > ./queue/tasks/3_samurai${i}.yaml << EOF
# 侍${i}専用タスクファイル [sonnet]
task:
  task_id: null
  parent_cmd: null
  description: null
  complexity: null  # high/medium/low
  status: idle
  timestamp: ""
EOF
done

# 足軽タスクファイルリセット（haiku × 2）
for i in {1..2}; do
    cat > ./queue/tasks/4_ashigaru${i}.yaml << EOF
# 足軽${i}専用タスクファイル [haiku]
task:
  task_id: null
  parent_cmd: null
  description: null
  assigned_by: null
  status: idle
  timestamp: ""
EOF
done

# 忍者レポートファイル作成
cat > ./queue/reports/7_ninja_report.yaml << EOF
worker_id: ninja
task_id: null
timestamp: ""
status: idle
classification: null
result: null
techniques_used: []
EOF

# 侍レポートファイルリセット（3人）
for i in {1..3}; do
    cat > ./queue/reports/3_samurai${i}_report.yaml << EOF
worker_id: samurai${i}
task_id: null
timestamp: ""
status: idle
result: null
quality_score: null
EOF
done

# 足軽レポートファイルリセット（2人）
for i in {1..2}; do
    cat > ./queue/reports/4_ashigaru${i}_report.yaml << EOF
worker_id: ashigaru${i}
task_id: null
timestamp: ""
status: idle
result: null
EOF
done


log_success "✅ タスク・報告ファイル初期化完了"
exit 0
