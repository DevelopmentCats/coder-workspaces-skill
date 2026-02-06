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

## Troubleshooting

| Issue | Fix |
|-------|-----|
| CLI not installed | `./scripts/setup.sh` |
| Version mismatch | `./scripts/setup.sh` |
| Auth failed | `./scripts/authenticate.sh` |

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

### Task Creation Workflow

Creating a task requires a **template** and usually a **preset**. Follow these steps:

#### Step 1: List Available Templates

```bash
coder templates list
```

#### Step 2: Find Presets for a Template

```bash
./scripts/list-presets.sh <template-name>
```

#### Step 3: Create the Task

```bash
coder tasks create \
  --template <template-name> \
  --preset "<preset-name>" \
  "Your prompt describing what the agent should do"
```

### Task Commands

```bash
coder tasks list                           # List all tasks
coder tasks                                # Same as list
coder tasks logs <task-name>               # View task output
coder tasks connect <task-name>            # Interactive session
```

### Task States

Tasks take 1-3 minutes to start:

- **Initializing** (30-120s): Workspace provisioning
- **Working**: Setup script running
- **Active**: Agent processing your prompt
- **Idle**: Agent waiting for input

## More Info

- [Coder Docs](https://coder.com/docs)
- [Coder Tasks](https://coder.com/docs/ai-coder)
