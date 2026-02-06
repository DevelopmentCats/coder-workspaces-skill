# Coder Workspaces Skill for OpenClaw

🏗️ Manage [Coder](https://coder.com) workspaces and AI coding agent tasks directly from your OpenClaw agent.

## What This Skill Does

This skill enables your OpenClaw agent to:

- **Manage Workspaces** — List, create, start, stop, restart, and delete Coder workspaces
- **Execute Commands** — SSH into workspaces and run commands remotely
- **AI Coding Tasks** — Create and manage Coder Tasks with AI agents (Claude Code, Aider, Goose, etc.)
- **Monitor & Troubleshoot** — View logs, check status, diagnose issues

## Quick Start

### 1. Install the Skill

```bash
clawhub install coder-workspaces
```

Or manually copy to your OpenClaw skills directory.

### 2. Install the Coder CLI

```bash
# From your Coder instance (recommended - matches server version)
curl -fsSL https://your-coder-url.com/install.sh | sh

# Or standalone
curl -fsSL https://coder.com/install.sh | sh -s -- --method standalone --prefix ~/.local
```

### 3. Configure Authentication

The skill requires two environment variables:

| Variable | Description | How to Get It |
|----------|-------------|---------------|
| `CODER_URL` | Your Coder deployment URL | e.g., `https://coder.example.com` |
| `CODER_SESSION_TOKEN` | Authentication token | See below |

**Getting your session token:**

1. **Via CLI Auth:** Run `coder login https://your-coder-url.com` and follow the prompts
2. **Via Web UI:** Go to `https://your-coder-url.com/cli-auth` and copy the token
3. **Via Settings:** Create a token at `https://your-coder-url.com/settings/tokens`

**Setting the environment variables:**

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export CODER_URL="https://your-coder-url.com"
export CODER_SESSION_TOKEN="your-token-here"
```

For OpenClaw specifically, you can also add these to the gateway environment or your workspace config.

### 4. Verify Setup

Ask your OpenClaw agent:

> "List my Coder workspaces"

Or run directly:

```bash
coder list
```

## Usage Examples

Once configured, just ask your OpenClaw agent naturally:

### Workspace Management

> "List all my running Coder workspaces"

> "Start my dev-environment workspace"

> "Show me the logs for my backend workspace"

> "SSH into my frontend workspace and run npm install"

### AI Coding Tasks

> "Create a Coder task to fix the authentication bug in login.py"

> "Check the status of my current coding tasks"

> "Send additional context to my running task about the database schema"

### Troubleshooting

> "Why is my workspace unhealthy? Diagnose it."

> "My task is stuck initializing — what's wrong?"

## Important Notes

### Presets Required for Tasks

Most Coder task templates require a **preset** to provide parameters like `setup_script` and `system_prompt`. The skill handles this automatically by:

1. Detecting available presets for the template
2. Using the default preset if one exists
3. Prompting you to choose if multiple presets are available

### Task Startup Timing

AI coding tasks go through several phases:

| Phase | Duration | What's Happening |
|-------|----------|------------------|
| `initializing` | 30-120s | Workspace provisioning |
| `working` | Varies | Agent executing setup script |
| `active` | — | Agent ready and processing |

**Expect 1-3 minutes for task startup** — this is normal.

## Included Resources

```
coder-workspaces/
├── SKILL.md                    # Main skill instructions
├── references/
│   ├── cli-commands.md         # Complete CLI reference
│   └── tasks.md                # AI coding tasks deep dive
└── scripts/
    └── coder-helper.sh         # Helper script for common operations
```

## Requirements

- **Coder CLI** (`coder`) — Install from your Coder instance
- **Coder Deployment** — Self-hosted or Coder Cloud
- **Environment Variables** — `CODER_URL` and `CODER_SESSION_TOKEN`

## Links

- [Coder Documentation](https://coder.com/docs)
- [Coder Tasks (AI Agents)](https://coder.com/docs/tasks)
- [OpenClaw](https://openclaw.ai)
- [ClawHub](https://clawhub.ai)

## License

MIT — Use freely, contribute back if you improve it!

---

*Built with 🐱 by [Meow](https://github.com/DevelopmentCats) for the OpenClaw community*
