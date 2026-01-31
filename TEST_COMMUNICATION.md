# 通信テスト手順書

## 修正内容の確認

2026-01-31に実施した重要な修正：

### 1. 報告メカニズムの修正
- **問題**: send-keys禁止により、上位階層が作業完了を知る術がなかった
- **解決**: 全階層でsend-keys通知を必須化

### 2. 修正ファイル一覧
- `CLAUDE.md` - 通信プロトコルの更新
- `instructions/2_karo.md` - 家老の報告ルール修正
- `instructions/3_samurai.md` - 侍の報告手順追加
- `instructions/4_ashigaru.md` - 足軽の報告手順追加
- `instructions/5_ninja.md` - 忍者の報告手順追加
- `shutsujin_departure.sh` - 待機時間延長（0.5秒→1秒）

## テスト手順

### 1. システム起動テスト
```bash
# システムを起動
./shutsujin_departure.sh

# 各エージェントが指示書を読み込んだか確認
tmux capture-pane -t shogun -p | grep "instructions/1_shogun.md"
tmux capture-pane -t multiagent:0.0 -p | grep "instructions/2_karo.md"
```

### 2. 通信フローテスト

#### 将軍→家老の通信テスト
```bash
# 将軍セッションにアタッチ
tmux attach-session -t shogun

# 将軍から指示を出す（将軍のClaude内で）
cat > queue/shogun_to_karo.yaml << EOF
queue:
  - id: cmd_test_001
    timestamp: "$(date +%Y-%m-%dT%H:%M:%S)"
    command: "通信テストを実施せよ"
    priority: high
    status: pending
EOF

# 家老に通知（2回に分ける）
tmux send-keys -t multiagent:0.0 'queue/shogun_to_karo.yaml に新しい指示がある。確認して実行せよ。'
tmux send-keys -t multiagent:0.0 Enter
```

#### 家老→実働部隊の通信テスト
```bash
# 家老セッションで確認
tmux attach-session -t multiagent

# 家老が侍にタスクを割り当てたか確認
cat queue/tasks/3_samurai1.yaml
```

#### 実働部隊→家老の報告テスト
```bash
# 侍が作業完了後、以下が実行されるか確認：
# 1. 報告ファイル更新
cat queue/reports/3_samurai1_report.yaml

# 2. dashboard.md 更新
cat dashboard.md | grep "戦果"

# 3. 家老への通知が送信されたか
tmux capture-pane -t multiagent:0.0 -p | grep "任務完了"
```

#### 家老→将軍の報告テスト
```bash
# 家老が将軍に通知を送ったか確認
tmux capture-pane -t shogun -p | grep "dashboard.md を更新した"
```

## 期待される動作

### 正常系
1. 将軍が指示 → 家老が受信して「はっ！」と応答
2. 家老がタスク分解 → 実働部隊に割り当て
3. 実働部隊が作業 → 完了後、家老に通知
4. 家老がdashboard.md更新 → 将軍に通知
5. 将軍がdashboard.md確認 → 殿に報告

### 異常系の確認点
- send-keysのEnterが届かない → メッセージだけ表示され実行されない
- 待機時間不足 → Claudeが起動前にメッセージ送信され無視される
- 報告ファイルパス間違い → ファイルが見つからないエラー

## トラブルシューティング

### 問題: 指示書が読み込まれない
```bash
# 手動で再送信
tmux send-keys -t multiagent:0.0 'instructions/2_karo.md を読んで役割を理解せよ。'
sleep 1
tmux send-keys -t multiagent:0.0 Enter
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
tmux capture-pane -t multiagent:0.0 -p | tail -5
```

## 検証項目チェックリスト

- [ ] 起動時に全エージェントが指示書を読み込む
- [ ] 将軍→家老の指示が届く
- [ ] 家老→実働部隊のタスク割り当てが届く
- [ ] 実働部隊→家老の完了報告が届く
- [ ] 家老→将軍の完了通知が届く
- [ ] dashboard.mdが更新される
- [ ] 殿（shogunセッション）の入力が妨げられない

## 備考

- send-keysは必ず2回のBash呼び出しに分ける
- 待機時間は環境により調整が必要（遅いマシンは延長）
- 報告ファイルのパスは役職により異なる（3_samurai, 4_ashigaru, 7_ninja）