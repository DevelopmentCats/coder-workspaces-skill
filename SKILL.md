---
name: coder-workspaces
description: Manage Coder workspaces and AI coding agent tasks via the Coder CLI. Use when you need to list, create, start, stop, restart, or delete workspaces; SSH into workspaces to run commands; view workspace logs; send tasks to AI coding agents (Claude Code, Aider, etc.); troubleshoot workspace issues; or check workspace status. Requires pre-configured coder CLI with CODER_URL and CODER_SESSION_TOKEN.
metadata:
  openclaw:
    emoji: "🏗️"
    requires:
      bins: ["coder"]
      env: ["CODER_URL", "CODER_SESSION_TOKEN"]
---

# Coder Workspaces

Manage Coder workspaces and AI coding agent tasks via the Coder CLI.

**Prerequisites:** The coder CLI must be installed and authenticated before using this skill. See the README for setup instructions.

## Verify Setup

```bash
coder whoami
coder list
```

If these fail, the user needs to complete CLI setup first.

## Workspace Commands

### List Workspaces

```bash
coder list
coder list --all
coder list --search "status:running"
coder list -o json
```

### Workspace Lifecycle

```bash
coder start <workspace>
coder stop <workspace>
coder restart <workspace> -y
coder delete <workspace> -y
```

### SSH and Command Execution

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

## AI Coding Agent Tasks

Coder Tasks runs AI agents (Claude Code, Aider, etc.) in isolated workspaces.

### Important: Presets Required

Most task templates require parameters. Always use a preset:

```bash
coder task create \
  --template <template-name> \
  --preset "<preset-name>" \
  "Your prompt here"
```

### List Available Templates and Presets

```bash
coder templates list
```

### Task Operations

```bash
coder task list
coder task status <task-name>
coder task logs <task-name>
coder task send <task-name> "Additional context"
coder task delete <task-name>
```

### Task Lifecycle Timing

Tasks go through several phases:

| Phase | Duration | What's Happening |
|-------|----------|------------------|
| initializing | 30-120s | Workspace provisioning |
| working | Varies | Agent executing setup |
| active | — | Agent ready |
| idle | — | Agent waiting for input |

Typical startup: 1-3 minutes.

## Troubleshooting

### Check Workspace Status

```bash
coder list --search "name:<workspace>" -o json
```

### View Build Logs

```bash
coder logs <workspace>
```

### Test Connectivity

```bash
coder ping <workspace>
```

### Restart Unhealthy Workspace

```bash
coder restart <workspace> -y
```

## More Information

For complete CLI documentation, see: https://coder.com/docs/cli
