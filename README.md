# multi-agent-shogun-kai

<div align="center">

**Multi-Agent Orchestration System for Claude Code**

*One command. Seven AI agents working in parallel.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai)
[![tmux](https://img.shields.io/badge/tmux-required-green)](https://github.com/tmux/tmux)

[English](README.md) | [Japanese / 日本語](README_ja.md)

</div>

---

## What is this?

**multi-agent-shogun-kai** 

A modified version of the excellent multi-agent system [**multi-agent-shogun**](https://github.com/yohey-w/multi-agent-shogun).

* Cost optimization
* Simplified configuration

**multi-agent-shogun** is a system that runs multiple Claude Code instances simultaneously, organized like a feudal Japanese army.

**Why use this?**
- Give one command, get 7 AI workers executing in parallel
- No waiting - you can keep giving commands while tasks run in background
- AI remembers your preferences across sessions (Memory MCP)
- Real-time progress tracking via dashboard

```
        You (The Lord)
             │
             ▼ Give orders
      ┌─────────────┐
      │   SHOGUN    │  ← Receives your command, manages tasks directly
      └──────┬──────┘
             │ YAML files + tmux
    ┌────────┼────────┐
    │        │        │
    ▼        ▼        ▼
┌───────┐ ┌────┐ ┌────────┐
│SAMURAI│ │ASHI│ │ NINJA  │  ← 6 workers execute in parallel
│  x3   │ │x2  │ │   x1   │
└───────┘ └────┘ └────────┘
```

---

## 🚀 Quick Start

### 🪟 Windows Users (Most Common)

<table>
<tr>
<td width="60">

**Step 1**

</td>
<td>

📥 **Download this repository**

[Download ZIP](https://github.com/yohey-w/multi-agent-shogun/archive/refs/heads/main.zip) and extract to `C:\tools\multi-agent-shogun`

*Or use git:* `git clone https://github.com/yohey-w/multi-agent-shogun.git C:\tools\multi-agent-shogun`

</td>
</tr>
<tr>
<td>

**Step 2**

</td>
<td>

🖱️ **Run `install.bat`**

Right-click and select **"Run as administrator"** (required if WSL2 is not yet installed). The installer will guide you through each step — you may need to restart your PC or set up Ubuntu before re-running.

</td>
</tr>
<tr>
<td>

**Step 3**

</td>
<td>

🐧 **Open Ubuntu and run** (first time only)

```bash
cd /mnt/c/tools/multi-agent-shogun
./first_setup.sh
```

</td>
</tr>
<tr>
<td>

**Step 4**

</td>
<td>

✅ **Deploy!**

```bash
./start.sh
```

</td>
</tr>
<tr>
<td>

**Step 5**

</td>
<td>

🔗 **Connect to the session!**

Open a new terminal and run:

```bash
./attach.sh
```

</td>
</tr>
</table>

#### 📅 Daily Startup (After First Install)

Open **Ubuntu terminal** (WSL) and run:

```bash
cd /mnt/c/tools/multi-agent-shogun
./start.sh
```

Then open a new terminal and connect:

```bash
./attach.sh
```

---

<details>
<summary>🐧 <b>Linux / Mac Users</b> (Click to expand)</summary>

### First-Time Setup

```bash
# 1. Clone the repository
git clone https://github.com/yohey-w/multi-agent-shogun.git ~/multi-agent-shogun
cd ~/multi-agent-shogun

# 2. Make scripts executable
chmod +x *.sh

# 3. Run first-time setup
./first_setup.sh
```

### Daily Startup

```bash
cd ~/multi-agent-shogun
./start.sh

# Then open a new terminal and connect:
./attach.sh
```

</details>

---

<details>
<summary>❓ <b>What is WSL2? Why do I need it?</b> (Click to expand)</summary>

### About WSL2

**WSL2 (Windows Subsystem for Linux)** lets you run Linux inside Windows. This system uses `tmux` (a Linux tool) to manage multiple AI agents, so WSL2 is required on Windows.

### Don't have WSL2 yet?

No problem! When you run `install.bat`, it will:
1. Check if WSL2 is installed (auto-install if missing)
2. Check if Ubuntu is installed (auto-install if missing)
3. Guide you to the next steps (`first_setup.sh`)

**Quick install command** (run in PowerShell as Administrator):
```powershell
wsl --install
```

Then restart your computer and run `install.bat` again.

</details>

---

<details>
<summary>📋 <b>Script Reference</b> (Click to expand)</summary>

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `install.bat` | Windows: WSL2 + Ubuntu setup | First time only |
| `first_setup.sh` | Installs tmux, Node.js, Claude Code CLI + configures Memory MCP | First time only |
| `start.sh` | Creates tmux sessions + starts Claude Code + loads instructions | Every day |
| `attach.sh` | Connects to the running tmux session | Every day (after start.sh) |

### What `install.bat` does automatically:
- ✅ Checks if WSL2 is installed (auto-install if missing)
- ✅ Checks if Ubuntu is installed (auto-install if missing)
- ✅ Guides you to the next steps (`first_setup.sh`)

### What `start.sh` does:
- ✅ Creates tmux session (shogun: 7 panes integrated)
- ✅ Launches Claude Code on all agents
- ✅ Automatically loads instruction files for each agent
- ✅ Resets queue files for a fresh start

**After running, all agents are ready to receive commands immediately!**

</details>

---

<details>
<summary>🔧 <b>Prerequisites (for manual setup)</b> (Click to expand)</summary>

If you prefer to install dependencies manually:

| Requirement | How to install | Notes |
|-------------|----------------|-------|
| WSL2 + Ubuntu | `wsl --install` in PowerShell | Windows only |
| Set Ubuntu as default | `wsl --set-default Ubuntu` | Required for scripts to work |
| tmux | `sudo apt install tmux` | Terminal multiplexer |
| Node.js v20+ | `nvm install 20` | Required for Claude Code CLI |
| Claude Code CLI | `npm install -g @anthropic-ai/claude-code` | Anthropic's official CLI |

</details>

---

### ✅ What Happens After Setup

After running either option, **7 AI agents** will start automatically:

| Agent | Role | Quantity |
|-------|------|----------|
| 🏯 Shogun | Commander - receives orders, manages tasks | 1 |
| ⚔️ Samurai | Core implementation - features, design | 3 |
| 👤 Ashigaru | Support work - simple tasks | 2 |
| 🥷 Ninja | Emergency response - critical tasks | 1 |

You'll see tmux session created:
- `multiagent` - All agents integrated (7 panes)

---

## 📖 Basic Usage

### Step 1: Connect to Shogun

After running `start.sh`, all agents automatically load their instructions and are ready to work.

Open a new terminal and connect:

```bash
./attach.sh
```

### Step 2: Give Your First Order

The Shogun is already initialized! Just give your command:

```
Investigate the top 5 JavaScript frameworks and create a comparison table.
```

The Shogun will:
1. Analyze the task and break it down
2. Assign work to Samurai/Ashigaru/Ninja via YAML files
3. Return control to you immediately (you don't have to wait!)

Meanwhile, the workers execute their assigned tasks in parallel.

### Step 3: Check Progress

Open `dashboard.md` in your editor to see real-time status:

```markdown
## In Progress
| Worker | Task | Status |
|--------|------|--------|
| Ashigaru 1 | React research | Running |
| Ashigaru 2 | Vue research | Running |
| Ashigaru 3 | Angular research | Done |
```

---

## ✨ Key Features

### ⚡ 1. Parallel Execution

One command can spawn up to 6 parallel tasks:

```
You: "Research 5 MCP servers"
→ 3 Samurai + 2 Ashigaru start researching simultaneously
→ Results ready in minutes, not hours
```

### 🔄 2. Non-Blocking Workflow

The Shogun delegates immediately and returns control to you:

```
You: Give order → Shogun: Delegates → You: Can give next order immediately
                                           ↓
                         Workers: Execute in background
                                           ↓
                         Dashboard: Shows results
```

You never have to wait for long tasks to complete.

### 🧠 3. Memory Across Sessions (Memory MCP)

The AI remembers your preferences:

```
Session 1: You say "I prefer simple solutions"
           → Saved to Memory MCP

Session 2: AI reads memory at startup
           → Won't suggest over-engineered solutions
```

### 📡 4. Event-Driven (No Polling)

Agents communicate via YAML files and wake each other with tmux send-keys.
**No API calls are wasted on polling loops.**

### 📸 5. Screenshot Support

VSCode's Claude Code extension lets you paste screenshots to explain issues. This CLI system brings the same capability:

```
# Configure your screenshot folder in config/settings.yaml
screenshot:
  path: "/mnt/c/Users/YourName/Pictures/Screenshots"

# Then just tell the Shogun:
You: "Check the latest screenshot"
You: "Look at the last 2 screenshots"
→ AI reads and analyzes your screenshots instantly
```

**💡 Windows Tip:** Press `Win + Shift + S` to take a screenshot. Configure the save location to match your `settings.yaml` path for seamless integration.

Perfect for:
- Explaining UI bugs visually
- Showing error messages
- Comparing before/after states

### 🧠 Model Configuration

| Agent | Model | Reason |
|-------|-------|--------|
| Shogun | Opus | Strategy & task management require high-level judgment |
| Samurai | Sonnet | Core implementation needs balanced capability |
| Ashigaru | Haiku | Simple tasks - fast and cost-effective |
| Ninja | Opus | Emergency/security work requires elite capability |

Cost ratio: Opus:Sonnet:Haiku ≈ 15:3:1

### 📁 Context Management

The system uses a three-layer context structure for efficient knowledge sharing:

| Layer | Location | Purpose |
|-------|----------|---------|
| Memory MCP | `memory/shogun_memory.jsonl` | Persistent memory across sessions (preferences, decisions) |
| Global | `memory/global_context.md` | System-wide settings, user preferences |
| Project | `context/{project}.md` | Project-specific knowledge and state |

This design allows:
- Any Ashigaru to pick up work on any project
- Consistent context across agent switches
- Clear separation of concerns
- Knowledge persistence across sessions

### Universal Context Template

All projects use the same 7-section template:

| Section | Purpose |
|---------|---------|
| What | Brief description of the project |
| Why | Goals and success criteria |
| Who | Stakeholders and responsibilities |
| Constraints | Deadlines, budget, limitations |
| Current State | Progress, next actions, blockers |
| Decisions | Decision log with rationale |
| Notes | Free-form notes and insights |

This standardized structure ensures:
- Quick onboarding for any agent
- Consistent information across all projects
- Easy handoffs between Ashigaru workers

### 🛠️ Skills

Skills are not included in this repository by default.
As you use the system, skill candidates will appear in `dashboard.md`.
Review and approve them to grow your personal skill library.

---

## 🏛️ Design Philosophy

### Why Hierarchical Structure?

The Shogun → Workers (Samurai/Ashigaru/Ninja) hierarchy exists for:

1. **Immediate Response**: Shogun delegates instantly and returns control to you
2. **Parallel Execution**: Shogun distributes to 6 workers simultaneously
3. **Cost Optimization**: Right model for the right task (Opus/Sonnet/Haiku)

### Why YAML + send-keys?

- **YAML files**: Structured communication that survives agent restarts
- **send-keys**: Event-driven wakeups (no polling = no wasted API calls)
- **No direct calls**: Agents can't interrupt each other or your input

### Why Only Shogun Updates Dashboard?

- **Single responsibility**: One writer = no conflicts
- **Information hub**: Shogun receives all reports, knows the full picture
- **Consistency**: All updates go through one quality gate

### How Skills Work

Skills (`.claude/commands/`) are **not committed to this repository** by design.

**Why?**
- Each user's workflow is different
- Skills should grow organically based on your needs
- No one-size-fits-all solution

**How to create new skills:**
1. Workers report "skill candidates" when they notice repeatable patterns
2. Candidates appear in `dashboard.md` under "Skill Candidates"
3. You review and approve (or reject)
4. Approved skills are created by Shogun

This keeps skills **user-driven** — only what you find useful gets added.

---

## 🔌 MCP Setup Guide

MCP (Model Context Protocol) servers extend Claude's capabilities. Here's how to set them up:

### What is MCP?

MCP servers give Claude access to external tools:
- **Notion MCP** → Read/write Notion pages
- **GitHub MCP** → Create PRs, manage issues
- **Memory MCP** → Remember things across sessions

### Installing MCP Servers

Run these commands to add MCP servers:

```bash
# 1. Notion - Connect to your Notion workspace
claude mcp add notion -e NOTION_TOKEN=your_token_here -- npx -y @notionhq/notion-mcp-server

# 2. Playwright - Browser automation
claude mcp add playwright -- npx @playwright/mcp@latest
# Note: Run `npx playwright install chromium` first

# 3. GitHub - Repository operations
claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=your_pat_here -- npx -y @modelcontextprotocol/server-github

# 4. Sequential Thinking - Step-by-step reasoning for complex problems
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

# 5. Memory - Long-term memory across sessions (Recommended!)
# ✅ Automatically configured by first_setup.sh
# To reconfigure manually:
claude mcp add memory -e MEMORY_FILE_PATH="$PWD/memory/shogun_memory.jsonl" -- npx -y @modelcontextprotocol/server-memory
```

### Verify Installation

```bash
claude mcp list
```

You should see all servers with "Connected" status.

---

## 🌍 Real-World Use Cases

### Example 1: Research Task

```
You: "Research the top 5 AI coding assistants and compare them"

What happens:
1. Shogun breaks down task and assigns:
   - Samurai 1: Research GitHub Copilot
   - Samurai 2: Research Cursor
   - Samurai 3: Research Claude Code
   - Ashigaru 1: Research Codeium
   - Ashigaru 2: Research Amazon CodeWhisperer
2. All 5 research simultaneously
3. Results compiled in dashboard.md
```

### Example 2: PoC Preparation

```
You: "Prepare a PoC for the project in this Notion page: [URL]"

What happens:
1. Shogun fetches Notion content via MCP
2. Samurai 1: Lists items to clarify
3. Samurai 2: Researches technical feasibility
4. Samurai 3: Creates PoC plan document
5. All results in dashboard.md, ready for your meeting
```

---

## ⚙️ Configuration

### Language Setting

Edit `config/settings.yaml`:

```yaml
language: ja   # Japanese only
language: en   # Japanese + English translation
```

---

## 🛠️ Advanced Usage

<details>
<summary><b>Script Architecture</b> (Click to expand)</summary>

```
┌─────────────────────────────────────────────────────────────────────┐
│                      FIRST-TIME SETUP (Run Once)                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  install.bat (Windows)                                              │
│      │                                                              │
│      ├── Check/Install WSL2                                         │
│      └── Check/Install Ubuntu                                       │
│                                                                     │
│  first_setup.sh (run manually in Ubuntu/WSL)                        │
│      │                                                              │
│      ├── Check/Install tmux                                         │
│      ├── Check/Install Node.js v20+ (via nvm)                      │
│      ├── Check/Install Claude Code CLI                              │
│      └── Configure Memory MCP server                                │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                      DAILY STARTUP (Run Every Day)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  start.sh                                             │
│      │                                                              │
│      ├──▶ Create tmux session                                       │
│      │         • "multiagent" session (7 panes integrated)              │
│      │                                                              │
│      ├──▶ Reset queue files and dashboard                           │
│      │                                                              │
│      └──▶ Launch Claude Code on all agents                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

</details>

<details>
<summary><b>start.sh Options</b> (Click to expand)</summary>

```bash
# Default: Full startup (tmux sessions + Claude Code launch)
./start.sh

# Session setup only (without launching Claude Code)
./start.sh -s
./start.sh --setup-only

# Full startup + open Windows Terminal tabs
./start.sh -t
./start.sh --terminal

# Show help
./start.sh -h
./start.sh --help
```

</details>

<details>
<summary><b>Common Workflows</b> (Click to expand)</summary>

**Normal Daily Usage:**
```bash
./start.sh          # Start everything
./attach.sh         # Connect to give commands
```

**Debug Mode (manual control):**
```bash
./start.sh -s       # Create session only

# Get session name
SESSION_NAME=$(cat .session-name)

# Manually start Claude Code on specific agents
tmux send-keys -t ${SESSION_NAME}:0.0 'claude --dangerously-skip-permissions' Enter  # Shogun
tmux send-keys -t ${SESSION_NAME}:0.1 'claude --dangerously-skip-permissions' Enter  # Samurai 1
```

**Restart After Crash:**
```bash
# Get session name
SESSION_NAME=$(cat .session-name)

# Kill existing session
tmux kill-session -t $SESSION_NAME

# Start fresh
./start.sh
```

</details>

---

## 📁 File Structure

<details>
<summary><b>Click to expand file structure</b></summary>

```
multi-agent-shogun/
│
│  ┌─────────────────── SETUP SCRIPTS ───────────────────┐
├── install.bat               # Windows: First-time setup
├── first_setup.sh            # Ubuntu/Mac: First-time setup
├── start.sh                 # Daily startup (auto-loads instructions)
├── attach.sh                # Connect to running session
│  └────────────────────────────────────────────────────┘
│
├── instructions/             # Agent instruction files
│   ├── 1_shogun.md           # Commander instructions
│   ├── 3_samurai.md          # Core worker instructions
│   ├── 4_ashigaru.md         # Support worker instructions
│   └── 5_ninja.md            # Emergency response instructions
│
├── config/
│   └── settings.yaml         # Language and other settings
│
├── queue/                    # Communication files
│   ├── tasks/                # Individual worker task files
│   └── reports/              # Worker reports
│
├── memory/                   # Memory MCP storage
├── dashboard.md              # Real-time status overview
└── CLAUDE.md                 # Project context for Claude
```

</details>

---

## 🔧 Troubleshooting

<details>
<summary><b>MCP tools not working?</b></summary>

MCP tools are "deferred" and need to be loaded first:

```
# Wrong - tool not loaded
mcp__memory__read_graph()  ← Error!

# Correct - load first
ToolSearch("select:mcp__memory__read_graph")
mcp__memory__read_graph()  ← Works!
```

</details>

<details>
<summary><b>Agents asking for permissions?</b></summary>

Make sure to start with `--dangerously-skip-permissions`:

```bash
claude --dangerously-skip-permissions --system-prompt "..."
```

</details>

<details>
<summary><b>Workers stuck?</b></summary>

Check the worker's pane:
```bash
./attach.sh
# Use Ctrl+B then arrow keys to switch panes
```

</details>

---

## 📚 tmux Quick Reference

| Command | Description |
|---------|-------------|
| `./attach.sh` | Connect to session |
| `Ctrl+B` then `0-6` | Switch between panes |
| `Ctrl+B` then `d` | Detach (leave running) |
| `tmux kill-session -t $(cat .session-name)` | Stop session |

Pane layout: 0=Shogun, 1-3=Samurai, 4-5=Ashigaru, 6=Ninja

---

## 🙏 Credits

Based on [Claude-Code-Communication](https://github.com/Akira-Papa/Claude-Code-Communication) by Akira-Papa.

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

<div align="center">

**Command your AI army. Build faster.**

</div>
