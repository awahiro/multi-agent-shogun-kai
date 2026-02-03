# 通信テスト手順書

## 修正内容の確認

2026-02-01に実施した構造変更：

### 1. 構造の概要
- 将軍 → 実働部隊の2階層構造
- 将軍がタスク管理を直接担当

### 2. 修正ファイル一覧
- `CLAUDE.md` - 通信プロトコルの更新
- `instructions/1_shogun.md` - 将軍のタスク管理機能追加
- `instructions/3_samurai.md` - 侍の報告手順（将軍に直接報告）
- `instructions/4_ashigaru.md` - 足軽の報告手順（将軍に直接報告）
- `instructions/5_ninja.md` - 忍者の報告手順（将軍に直接報告）
- `start.sh` - 7ペイン統合レイアウト

## テスト手順

### 1. システム起動テスト
```bash
# システムを起動
./start.sh

# 各エージェントのペイン確認
tmux list-panes -t multiagent
# 期待: 7ペイン (0=将軍, 1-3=侍, 4-5=足軽, 6=忍者)
```

### 2. 通信フローテスト

#### 将軍→実働部隊の通信テスト
```bash
# 将軍セッションにアタッチ
tmux attach-session -t multiagent

# 将軍からタスクファイルを作成（将軍のClaude内で）
cat > queue/tasks/3_samurai1.yaml << EOF
task:
  task_id: test_001
  parent_cmd: cmd_test
  description: "通信テストを実施せよ"
  priority: high
  status: pending
EOF

# 侍1に通知（2回に分ける）
tmux send-keys -t multiagent:0.1 'queue/tasks/3_samurai1.yaml に新しいタスクがある。確認して実行せよ。'
tmux send-keys -t multiagent:0.1 Enter
```

#### 実働部隊→将軍の報告テスト
```bash
# 侍が作業完了後、以下が実行されるか確認：
# 1. 報告ファイル更新
cat queue/reports/3_samurai1_report.yaml

# 2. 将軍への通知が送信されたか
tmux capture-pane -t multiagent:0.0 -p | grep "任務完了"

# 3. dashboard.md が将軍により更新されたか
cat dashboard.md | grep "戦果"
```

## 期待される動作

### 正常系
1. 将軍がタスクをYAMLに書く → 実働部隊に send-keys で通知
2. 実働部隊が作業 → 完了後、報告ファイル更新 + 将軍に通知
3. 将軍がdashboard.md更新 → 殿に報告

### 異常系の確認点
- send-keysのEnterが届かない → メッセージだけ表示され実行されない
- 待機時間不足 → Claudeが起動前にメッセージ送信され無視される
- 報告ファイルパス間違い → ファイルが見つからないエラー

## トラブルシューティング

### 問題: タスクが届かない
```bash
# 手動でタスク通知を再送信
tmux send-keys -t multiagent:0.1 'queue/tasks/3_samurai1.yaml を確認せよ。'
sleep 1
tmux send-keys -t multiagent:0.1 Enter
```

### 問題: 報告が届かない
```bash
# 報告ファイルの内容確認
ls -la queue/reports/
cat queue/reports/*_report.yaml

# dashboard.mdの最終更新時刻確認
ls -la dashboard.md
```

### 問題: send-keysが効かない
```bash
# tmuxセッションの状態確認
tmux list-sessions
tmux list-panes -t multiagent

# ペインが存在するか確認
tmux capture-pane -t multiagent:0.1 -p | tail -5
```

## 検証項目チェックリスト

- [ ] 起動時に7ペインが作成される
- [ ] 将軍→実働部隊のタスク割り当てが届く
- [ ] 実働部隊→将軍の完了報告が届く
- [ ] dashboard.mdが将軍により更新される
- [ ] 殿（multiagent:0.0ペイン）の入力が妨げられない

## ペイン構成

```
┌─────────────────────────────────┐
│           将軍 (0.0)            │
├──────────┬──────────┬───────────┤
│ 侍1(0.1) │ 侍2(0.2) │ 侍3(0.3)  │
├──────────┼──────────┼───────────┤
│足軽1(0.4)│足軽2(0.5)│忍者(0.6)  │
└──────────┴──────────┴───────────┘
```

## 備考

- send-keysは必ず2回のBash呼び出しに分ける
- 待機時間は環境により調整が必要（遅いマシンは延長）
- 報告ファイルのパスは役職により異なる（3_samurai, 4_ashigaru, 7_ninja）
- dashboard.md の更新は将軍のみが行う（競合回避）
