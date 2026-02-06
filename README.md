# Coder Workspaces Skill for OpenClaw

Manage [Coder](https://coder.com) workspaces and AI coding agent tasks from your OpenClaw agent.

## Features

- **Workspaces**: List, create, start, stop, restart, delete
- **Remote Commands**: SSH into workspaces and run commands
- **AI Tasks**: Create and manage Coder Tasks with Claude Code, Aider, Goose, etc.
- **Self-Healing**: Diagnose and fix CLI issues automatically

## Prerequisites

1. Access to a Coder deployment (self-hosted or Coder Cloud)
2. Environment variables configured

## Setup

### 1. Set Environment Variables

Add to your OpenClaw config (`~/.openclaw/openclaw.json`):

```json
{
  "env": {
    "CODER_URL": "https://your-coder-deployment.com",
    "CODER_SESSION_TOKEN": "your-session-token"
  }
}
```

Get a token at `https://your-coder-deployment.com/cli-auth` or `/settings/tokens`.

### 2. Install and Authenticate

```bash
./scripts/setup.sh        # Install CLI from your instance
./scripts/authenticate.sh # Login with your token
```

### 3. Verify

```bash
coder whoami
```

## Install the Skill

```bash
clawhub install coder-workspaces
```

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `scripts/setup.sh` | Install/update CLI from instance |
| `scripts/authenticate.sh` | Login with session token |
| `scripts/list-presets.sh <template>` | List presets for a template |

## Usage

Ask your OpenClaw agent things like:

- "List my Coder workspaces"
- "Start my dev workspace"
- "Create a task to fix the auth bug"
- "Check status of my running tasks"
- "SSH into backend and run the tests"

## Troubleshooting

If something breaks:

- CLI missing or version mismatch → `./scripts/setup.sh`
- Auth failed → `./scripts/authenticate.sh`

## Links

- [Coder Docs](https://coder.com/docs)
- [Coder Tasks](https://coder.com/docs/ai-coder)
- [OpenClaw](https://openclaw.ai)
- [ClawHub](https://clawhub.com)

## License

MIT
