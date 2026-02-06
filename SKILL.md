---
name: coder-workspaces
description: Manage Coder workspaces and AI coding agent tasks via the Coder CLI. Use when you need to list, create, start, stop, restart, or delete workspaces; SSH into workspaces to run commands; view workspace logs; send tasks to AI coding agents (Claude Code, Aider, etc.); troubleshoot workspace issues; or check workspace status. Requires CODER_URL and CODER_SESSION_TOKEN configuration.
metadata:
  openclaw:
    emoji: "🏗️"
    requires:
      bins: ["coder"]
      env: ["CODER_URL", "CODER_SESSION_TOKEN"]
    install:
      - id: "coder-standalone"
        kind: "shell"
        command: "curl -fsSL https://coder.com/install.sh | sh -s -- --method standalone --prefix ~/.local"
        bins: ["coder"]
        label: "Install Coder CLI (standalone)"
---

# Coder Workspaces

Interact with Coder workspaces and AI coding agent tasks via the Coder CLI.

## Configuration

Set environment variables (preferred):

```bash
export CODER_URL="https://coder.example.com"
export CODER_SESSION_TOKEN="your-session-token"
```

Or use flags: `--url <url> --token <token>`

**Get a token:** Visit `https://<your-coder-url>/cli-auth` or create at `/settings/tokens`

## CLI Installation

```bash
# Install from your Coder instance (matches server version)
curl -fsSL https://<your-coder-url>/install.sh | sh

# Or standalone (may have version mismatch warnings)
curl -fsSL https://coder.com/install.sh | sh -s -- --method standalone --prefix ~/.local
```

**Note:** Version mismatches between client/server usually work but show warnings.

## Core Workspace Commands

### List Workspaces

```bash
coder list                        # List your workspaces
coder list --all                  # List all workspaces (if permitted)
coder list --search "status:running"  # Filter by status
coder list -o json                # JSON output for parsing
```

### Workspace Lifecycle

```bash
coder start <workspace>           # Start workspace
coder stop <workspace>            # Stop workspace  
coder restart <workspace> -y      # Restart (skip confirmation)
coder delete <workspace> -y       # Delete workspace
```

### SSH & Command Execution

```bash
coder ssh <workspace>             # Interactive shell
coder ssh <workspace> -- ls -la   # Run single command
coder ssh <workspace> -- "cd /app && npm test"  # Complex command
```

### View Logs

```bash
coder logs <workspace>            # View build logs
coder logs <workspace> -f         # Follow logs (streaming)
coder logs <workspace> -n -1      # Previous build logs
```

## AI Coding Agent Tasks

Coder Tasks runs AI agents (Claude Code, Aider, etc.) in isolated workspaces.

### ⚠️ Important: Presets Required

Most task templates require parameters like `setup_script` and `system_prompt`. **Always use a preset** unless you know the template has defaults:

```bash
# List available presets for a template (via API)
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templateversions/<version-id>/presets" | jq '.[].Name'
```

### Create Task (Recommended Pattern)

```bash
# Always specify --preset for templates with required parameters
coder task create \
  --template <template-name> \
  --preset "<preset-name>" \
  "Your prompt here"
```

Example:
```bash
coder task create \
  --template Tasks-test-preinstall \
  --preset "Real World App: Angular + Django" \
  "Fix the authentication bug in login.py"
```

### Task Operations

```bash
coder task list                   # List all tasks
coder task status <task-name>     # Check task status
coder task logs <task-name>       # View agent logs
coder task send <task-name> "Additional context"  # Send more instructions
coder task delete <task-name>     # Delete task
```

### Task Lifecycle Timing

Tasks go through several phases — **be patient**:

| Phase | Duration | What's Happening |
|-------|----------|------------------|
| `initializing` | 30-120s | Workspace provisioning |
| `working` | Varies | Agent executing setup script |
| `active` | — | Agent ready and processing |
| `idle` | — | Agent waiting for input |

**Typical startup:** 1-3 minutes depending on setup script complexity.

### Monitoring a Task

```bash
# Poll status every 30 seconds
while true; do
  coder task status <task-name>
  sleep 30
done

# Or watch for state changes
watch -n 10 'coder task status <task-name>'
```

## Troubleshooting Workflows

### Task Won't Create (Parameter Errors)

If you see "Required parameter not provided":

1. **Check for presets:**
   ```bash
   # Get template's active version
   TEMPLATE_ID=$(curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
     "$CODER_URL/api/v2/templates" | jq -r '.[] | select(.name=="<template>") | .active_version_id')
   
   # List presets
   curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
     "$CODER_URL/api/v2/templateversions/$TEMPLATE_ID/presets" | jq '.[].Name'
   ```

2. **Use the preset:**
   ```bash
   coder task create --template <name> --preset "<preset-name>" "prompt"
   ```

### Diagnose Unhealthy Workspace

```bash
# 1. Check status
coder list --search "name:<workspace>" -o json | jq '.[0].latest_build.status'

# 2. View recent build logs  
coder logs <workspace>

# 3. Check agent connectivity
coder ping <workspace>

# 4. Try restart
coder restart <workspace> -y
```

### Workspace Won't Start

```bash
# Force update to latest template
coder update <workspace> -y

# Check for resource issues
coder logs <workspace> -f
```

## API Quick Reference

For programmatic access when CLI isn't sufficient:

```bash
# List workspaces
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/workspaces?q=owner:me" | jq

# List tasks
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/tasks" | jq '.tasks'

# Get template presets
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templateversions/<version-id>/presets" | jq
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CODER_URL` | Coder deployment URL |
| `CODER_SESSION_TOKEN` | Authentication token |
| `CODER_TEMPLATE_NAME` | Default template |
| `CODER_CONFIG_DIR` | Config directory (default: ~/.config/coderv2) |

## References

- [CLI Commands](references/cli-commands.md) — Complete command reference
- [Tasks Guide](references/tasks.md) — AI coding agent tasks deep dive
