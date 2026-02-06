---
name: coder-workspaces
description: Manage Coder workspaces and AI coding agent tasks via CLI. List, create, start, stop, and delete workspaces. SSH into workspaces to run commands. Create and monitor AI coding tasks with Claude Code, Aider, or other agents. View logs and troubleshoot issues.
metadata:
  openclaw:
    emoji: "🏗️"
    requires:
      bins: ["coder"]
      env: ["CODER_URL", "CODER_SESSION_TOKEN"]
---

# Coder Workspaces

Manage Coder workspaces and AI coding agent tasks via the coder CLI.

The coder CLI must be installed and authenticated before using this skill. See README for setup.

## Verify Setup

```bash
coder whoami
coder list
```

## Workspace Commands

### List Workspaces

```bash
coder list
coder list --all
coder list --search "status:running"
coder list -o json
```

### Start, Stop, Restart, Delete

```bash
coder start <workspace>
coder stop <workspace>
coder restart <workspace> -y
coder delete <workspace> -y
```

### SSH and Run Commands

```bash
coder ssh <workspace>
coder ssh <workspace> -- ls -la
coder ssh <workspace> -- "cd /app && npm test"
```

### View Logs

```bash
coder logs <workspace>
coder logs <workspace> -f
```

## AI Coding Tasks

Coder Tasks runs AI agents (Claude Code, Aider, etc.) in isolated workspaces.

### Create a Task

Most templates require a preset:

```bash
coder task create \
  --template <template-name> \
  --preset "<preset-name>" \
  "Your prompt here"
```

### List Templates

```bash
coder templates list
```

### Task Commands

```bash
coder task list
coder task status <task-name>
coder task logs <task-name>
coder task send <task-name> "Additional context"
coder task delete <task-name>
```

### Task Startup Timing

Tasks take 1-3 minutes to start:

- **Initializing** (30-120s): Workspace provisioning
- **Working** (varies): Setup script running
- **Active**: Agent processing
- **Idle**: Agent waiting for input

## Troubleshooting

```bash
# Check workspace status
coder list --search "name:<workspace>" -o json

# View build logs
coder logs <workspace>

# Test connectivity
coder ping <workspace>

# Restart unhealthy workspace
coder restart <workspace> -y
```

## More Info

https://coder.com/docs/cli
