# Coder Workspaces Skill for OpenClaw

🏗️ Manage [Coder](https://coder.com) workspaces and AI coding agent tasks directly from your OpenClaw agent.

## What This Skill Does

This skill enables your OpenClaw agent to:

- **Manage Workspaces** — List, create, start, stop, restart, and delete Coder workspaces
- **Execute Commands** — SSH into workspaces and run commands remotely
- **AI Coding Tasks** — Create and manage Coder Tasks with AI agents (Claude Code, Aider, Goose, etc.)
- **Monitor & Troubleshoot** — View logs, check status, diagnose issues

## Prerequisites

Before using this skill, you must:

1. Have access to a Coder deployment (self-hosted or Coder Cloud)
2. Install and authenticate the Coder CLI
3. Set required environment variables

## Setup Instructions

### 1. Install the Coder CLI

Download from the official source:

1. Visit https://github.com/coder/coder/releases
2. Download the appropriate binary for your OS
3. Extract and add to your PATH

**Or use your package manager:**
- Homebrew: `brew install coder/coder/coder`
- See https://coder.com/docs/install for other methods

**Verify installation:**
```bash
coder version
```

### 2. Authenticate with Your Coder Deployment

```bash
coder login https://your-coder-deployment.com
```

This opens a browser for authentication and stores your credentials locally.

### 3. Set Environment Variables

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export CODER_URL="https://your-coder-deployment.com"
export CODER_SESSION_TOKEN="your-session-token"
```

**To get a session token:**
- Visit `https://your-coder-deployment.com/cli-auth`, or
- Create one at `https://your-coder-deployment.com/settings/tokens`

### 4. Verify Setup

```bash
coder whoami
coder list
```

## Install the Skill

```bash
clawhub install coder-workspaces
```

Or manually copy to your OpenClaw skills directory.

## Usage Examples

Once configured, ask your OpenClaw agent:

- "List my Coder workspaces"
- "Start my dev-environment workspace"
- "Create a Coder task to fix the authentication bug"
- "Check the status of my running tasks"
- "SSH into my backend workspace and run the tests"

## Important Notes

### Presets Required for Tasks

Most Coder task templates require a **preset**. The skill handles this by checking available presets and using the default when possible.

### Task Startup Time

AI coding tasks take 1-3 minutes to start (workspace provisioning + agent initialization). This is normal.

## Included Files

```
coder-workspaces/
├── SKILL.md             # Agent instructions
├── README.md            # This file (human setup guide)
├── CHANGELOG.md         # Version history
└── LICENSE              # MIT
```

## Links

- [Coder Documentation](https://coder.com/docs)
- [Coder Tasks](https://coder.com/docs/ai-coder)
- [OpenClaw](https://openclaw.ai)
- [ClawHub](https://clawhub.ai)

## License

MIT

---

*Built by [DevelopmentCats](https://github.com/DevelopmentCats) for the OpenClaw community*
