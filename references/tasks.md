# Coder Tasks — AI Coding Agent Management

Coder Tasks runs AI coding agents (Claude Code, Aider, Goose, etc.) in isolated workspaces.

## Table of Contents

- [Key Concepts](#key-concepts)
- [Creating Tasks](#creating-tasks)
- [Task Lifecycle](#task-lifecycle)
- [CLI Reference](#cli-reference)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Workflow Patterns](#workflow-patterns)

## Key Concepts

### Templates vs Presets

- **Template:** Defines the infrastructure and agent configuration (Terraform)
- **Preset:** Pre-configured parameter values for a template

**Critical:** Most task templates require parameters like `setup_script` and `system_prompt`. Without a preset, task creation will fail with "Required parameter not provided."

### Task States

| Status | State | Meaning |
|--------|-------|---------|
| `initializing` | `working` | Workspace provisioning, agent starting |
| `active` | `working` | Agent actively processing prompt |
| `active` | `idle` | Agent waiting for input |
| `paused` | `idle` | Workspace stopped |
| `error` | `idle` | Something went wrong |

## Creating Tasks

### Step 1: Find Available Presets

```bash
# Get template info
TEMPLATE_NAME="Tasks-test-preinstall"

# Get template's active version ID
VERSION_ID=$(curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templates" | \
  jq -r ".[] | select(.name==\"$TEMPLATE_NAME\") | .active_version_id")

# List presets
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templateversions/$VERSION_ID/presets" | \
  jq '.[] | {name: .Name, default: .Default}'
```

### Step 2: Create Task with Preset

```bash
coder task create \
  --template "$TEMPLATE_NAME" \
  --preset "Real World App: Angular + Django" \
  "Your prompt describing what the agent should do"
```

### Without Preset (If Template Has Defaults)

Only works if the template has non-required or defaulted parameters:

```bash
coder task create --template my-template "Fix the bug in auth.py"
```

## Task Lifecycle

### Timing Expectations

```
Creation → Initializing → Active → Idle/Complete
   |           |            |
   |        30-120s      Varies
   |     (provisioning)  (work)
   ↓
Immediate
```

**Startup phases:**
1. **Queued** (instant) — Job scheduled
2. **Running** (5-10s) — Terraform planning
3. **Starting workspace** (20-60s) — Container/VM creation
4. **Agent starting** (30-90s) — Setup script execution
5. **Active** — Agent processing prompt

**Total typical startup: 1-3 minutes**

### Monitoring Task Progress

```bash
# Quick status check
coder task status <task-name>

# Detailed status with message
coder task list | grep <task-name>

# Watch for changes
watch -n 15 'coder task status <task-name>'

# View agent output
coder task logs <task-name>
```

## CLI Reference

### coder task list

List all tasks with status.

```bash
coder task list
```

Output columns:
- `NAME` — Task identifier
- `STATUS` — Current status (initializing/active/paused/error)
- `STATE` — Activity state (working/idle)
- `STATE CHANGED` — Time since last state change
- `MESSAGE` — Agent's last status message

### coder task create

Create a new task.

```bash
coder task create [flags] <prompt>
```

**Flags:**
- `--template <name>` — Template to use
- `--template-version <version>` — Specific version
- `--preset <name>` — Preset with parameter values (**usually required**)
- `--name <name>` — Custom task name
- `--owner <user>` — Create for another user
- `-q, --quiet` — Only output task ID

**Examples:**
```bash
# With preset (recommended)
coder task create --template Tasks-test-preinstall \
  --preset "Real World App: Angular + Django" \
  "Add dark mode to the frontend"

# With custom name
coder task create --template my-template \
  --preset "Default" \
  --name "dark-mode-task" \
  "Implement dark mode toggle"
```

### coder task status

Get detailed task status.

```bash
coder task status <task-name>
```

Output shows: state changed time, status, health, state, and message.

### coder task logs

View task/agent logs.

```bash
coder task logs <task-name>
```

Shows the agent's output and any status messages.

### coder task send

Send additional prompts to a running task.

```bash
coder task send <task-name> "Additional instructions"
```

Useful for:
- Providing clarification
- Steering the agent in a different direction
- Adding context mid-task

### coder task delete

Delete a task and its workspace.

```bash
coder task delete <task-name>
```

## API Reference

### List Tasks

```bash
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/tasks" | jq '.tasks'
```

### Get Task Details

```bash
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/tasks" | \
  jq '.tasks[] | select(.name=="<task-name>")'
```

### Get Template Presets

```bash
# First get template's active version
TEMPLATE_ID="<template-uuid>"
VERSION_ID=$(curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templates/$TEMPLATE_ID" | jq -r '.active_version_id')

# Then get presets
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templateversions/$VERSION_ID/presets" | jq
```

### Get Template Parameters

```bash
curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templateversions/$VERSION_ID/rich-parameters" | \
  jq '.[] | {name, required, default_value}'
```

## Troubleshooting

### "Required parameter not provided"

**Cause:** Template requires `setup_script`, `system_prompt`, or other parameters.

**Solution:**
1. List available presets for the template
2. Use `--preset "<preset-name>"` when creating the task

### Task Stuck in "initializing"

**Normal duration:** Up to 3 minutes for complex setup scripts.

**If longer:**
1. Check workspace logs: `coder logs <task-workspace-name>`
2. Check task status message: `coder task status <task-name>`
3. The setup script might be installing packages or cloning repos

### Task Shows "error" Status

1. Check task logs: `coder task logs <task-name>`
2. Check workspace build logs: `coder logs <task-workspace-name>`
3. Common causes:
   - Missing API keys (Anthropic, OpenAI)
   - Network issues in workspace
   - Setup script failures

### Version Mismatch Warnings

```
version mismatch: client v2.30.0, server v2.29.3
```

**Usually safe to ignore.** To match versions:
```bash
curl -fsSL https://<your-coder-url>/install.sh | sh
```

## Workflow Patterns

### Create Task and Wait for Completion

```bash
#!/bin/bash
TASK_NAME=$(coder task create -q \
  --template my-template \
  --preset "Default" \
  "Fix the authentication bug")

echo "Created task: $TASK_NAME"

# Wait for active state
while true; do
  STATUS=$(coder task status "$TASK_NAME" 2>/dev/null | awk 'NR==2 {print $2}')
  STATE=$(coder task status "$TASK_NAME" 2>/dev/null | awk 'NR==2 {print $4}')
  
  echo "Status: $STATUS, State: $STATE"
  
  if [[ "$STATUS" == "active" && "$STATE" == "idle" ]]; then
    echo "Task completed!"
    break
  elif [[ "$STATUS" == "error" ]]; then
    echo "Task failed!"
    exit 1
  fi
  
  sleep 30
done

# Show results
coder task logs "$TASK_NAME"
```

### Batch Create Multiple Tasks

```bash
#!/bin/bash
PROMPTS=(
  "Add unit tests for user service"
  "Document the API endpoints"
  "Fix the CSS layout bug"
)

for PROMPT in "${PROMPTS[@]}"; do
  TASK_NAME=$(coder task create -q \
    --template my-template \
    --preset "Default" \
    "$PROMPT")
  echo "Created: $TASK_NAME"
done
```

### Interactive Task Session

```bash
# Create task
TASK=$(coder task create -q --template my-template --preset "Default" "Initial prompt")

# Wait for it to start
sleep 60

# Send follow-up instructions
coder task send "$TASK" "Focus on error handling first"

# Later, provide more context
coder task send "$TASK" "The auth module is in src/auth/"
```

## Best Practices

1. **Always check for presets first** — Most templates need them
2. **Be patient with startup** — 1-3 minutes is normal
3. **Use descriptive prompts** — The agent works better with clear instructions
4. **Monitor with `task status`** — The MESSAGE field shows agent progress
5. **Send context as needed** — Use `task send` to steer the agent
6. **Clean up old tasks** — Delete completed/failed tasks to free resources
