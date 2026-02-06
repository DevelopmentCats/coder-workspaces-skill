# Coder Workspaces Skill for OpenClaw

Manage [Coder](https://coder.com) workspaces and AI coding agent tasks from your OpenClaw agent.

## Features

- **Workspaces**: List, create, start, stop, restart, delete
- **Remote Commands**: SSH into workspaces and run commands
- **AI Tasks**: Create and manage Coder Tasks with Claude Code, Aider, Goose, etc.
- **Monitoring**: View logs, check status, troubleshoot issues

## Prerequisites

1. Access to a Coder deployment (self-hosted or Coder Cloud)
2. Coder CLI installed and authenticated
3. Environment variables configured

## Setup

### 1. Install the Coder CLI

Download from [GitHub Releases](https://github.com/coder/coder/releases) or see [installation docs](https://coder.com/docs/install).

Verify:
```bash
coder version
```

### 2. Authenticate

```bash
coder login https://your-coder-deployment.com
```

### 3. Set Environment Variables

Add to your shell profile:

```bash
export CODER_URL="https://your-coder-deployment.com"
export CODER_SESSION_TOKEN="your-session-token"
```

Get a token at `https://your-coder-deployment.com/cli-auth` or `/settings/tokens`.

### 4. Verify

```bash
coder whoami
coder list
```

## Install the Skill

```bash
clawhub install coder-workspaces
```

## Usage

Ask your OpenClaw agent things like:

- "List my Coder workspaces"
- "Start my dev workspace"
- "Create a task to fix the auth bug"
- "Check status of my running tasks"
- "SSH into backend and run the tests"

## Notes

- Most task templates require a **preset** for configuration
- Tasks take 1-3 minutes to start (provisioning + agent init)

## Links

- [Coder Docs](https://coder.com/docs)
- [Coder Tasks](https://coder.com/docs/ai-coder)
- [OpenClaw](https://openclaw.ai)
- [ClawHub](https://clawhub.ai)

## License

MIT
