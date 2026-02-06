# Coder CLI Command Reference

Complete reference for Coder CLI commands relevant to workspace and task management.

## Table of Contents

- [Global Options](#global-options)
- [Workspace Commands](#workspace-commands)
- [SSH & Access](#ssh--access)
- [Task Commands](#task-commands)
- [Troubleshooting Commands](#troubleshooting-commands)
- [Template Commands](#template-commands)
- [User Commands](#user-commands)

## Global Options

Available on all commands:

| Flag | Env Variable | Description |
|------|--------------|-------------|
| `--url <url>` | `CODER_URL` | Coder deployment URL |
| `--token <token>` | `CODER_SESSION_TOKEN` | Session token |
| `--no-version-warning` | `CODER_NO_VERSION_WARNING` | Suppress version mismatch warnings |
| `--verbose`, `-v` | `CODER_VERBOSE` | Enable verbose output |
| `--global-config` | `CODER_CONFIG_DIR` | Config directory path |

## Workspace Commands

### coder list (alias: ls)

List workspaces.

```bash
coder list [flags]
```

**Flags:**
- `-a, --all` — List all workspaces (not just yours)
- `--search <query>` — Filter workspaces (default: "owner:me")
- `-c, --column <cols>` — Columns to display
- `-o, --output <format>` — Output format: table|json

**Search filters:**
- `owner:me` — Your workspaces
- `status:running` — Running workspaces
- `status:stopped` — Stopped workspaces
- `template:<name>` — By template
- `name:<name>` — By name (partial match)

### coder create

Create a workspace.

```bash
coder create [workspace-name] [flags]
```

**Flags:**
- `-t, --template <name>` — Template name (required)
- `--template-version <version>` — Specific template version
- `--preset <name>` — Use a template preset
- `--parameter <name=value>` — Set parameters (repeatable)
- `--rich-parameter-file <path>` — YAML file with parameters
- `--stop-after <duration>` — Auto-stop after duration (e.g., "8h")
- `--start-at <schedule>` — Autostart schedule
- `-y, --yes` — Skip confirmation prompts

### coder start

Start a stopped workspace.

```bash
coder start <workspace> [flags]
```

**Flags:**
- `--no-wait` — Return immediately
- `-y, --yes` — Skip confirmation
- `--parameter <name=value>` — Override parameters
- `--ephemeral-parameter <name=value>` — One-time parameters

### coder stop

Stop a running workspace.

```bash
coder stop <workspace> [flags]
```

### coder restart

Restart a workspace.

```bash
coder restart <workspace> [flags]
```

**Flags:**
- `-y, --yes` — Skip confirmation
- `--parameter <name=value>` — Override parameters

### coder delete

Delete a workspace.

```bash
coder delete <workspace> [flags]
```

**Flags:**
- `-y, --yes` — Skip confirmation

### coder update

Update workspace to latest template version.

```bash
coder update <workspace> [flags]
```

### coder show

Display workspace details including resources and agents.

```bash
coder show <workspace>
```

### coder logs

View workspace build logs.

```bash
coder logs <workspace> [flags]
```

**Flags:**
- `-f, --follow` — Stream logs as they come
- `-n, --build-number <n>` — Specific build (0=latest, -1=previous)

### coder rename

Rename a workspace.

```bash
coder rename <old-name> <new-name>
```

## SSH & Access

### coder ssh

Start shell or run commands in workspace.

```bash
coder ssh <workspace> [command]
```

**Flags:**
- `-A, --forward-agent` — Forward SSH agent
- `-G, --forward-gpg` — Forward GPG agent
- `-R, --remote-forward <port:addr:port>` — Remote port forwarding
- `-e, --env <key=value>` — Set environment variables
- `--wait <yes|no|auto>` — Wait for startup script
- `--no-wait` — Don't wait for startup script
- `-l, --log-dir <path>` — SSH log directory
- `--disable-autostart` — Don't auto-start stopped workspace

**Examples:**
```bash
# Interactive shell
coder ssh my-workspace

# Run command
coder ssh my-workspace -- ls -la

# Command with flags (use -- to separate)
coder ssh my-workspace -- grep -r "error" /var/log

# Set environment variable
coder ssh my-workspace -e "DEBUG=1" -- ./run-tests.sh
```

### coder config-ssh

Configure SSH for native SSH client access.

```bash
coder config-ssh [flags]
```

**Flags:**
- `-o, --ssh-option <option>` — Add SSH options
- `-n, --dry-run` — Preview changes without applying
- `--coder-binary-path <path>` — Custom coder binary path

After running, access workspaces with: `ssh coder.<workspace-name>`

### coder port-forward

Forward ports from workspace to local machine.

```bash
coder port-forward <workspace> --tcp <local>:<remote> [flags]
```

**Flags:**
- `--tcp <local:remote>` — TCP port forward
- `--udp <local:remote>` — UDP port forward

### coder ping

Test connectivity to workspace.

```bash
coder ping <workspace>
```

### coder speedtest

Test network speed to workspace.

```bash
coder speedtest <workspace>
```

## Task Commands

Commands for managing AI coding agent tasks (Claude Code, Aider, etc.).

**Note:** In older versions, use `coder exp task`. In v2.27+, use `coder task`.

### coder task list

List all tasks.

```bash
coder task list
```

### coder task create

Create a new AI agent task.

```bash
coder task create [flags] <prompt>
```

**Flags:**
- `--template <name>` — Task template (required)
- `--preset <name>` — Preset with parameter values (**usually required**)
- `--template-version <version>` — Specific template version
- `--name <name>` — Custom task name
- `--owner <user>` — Create for another user
- `-q, --quiet` — Only output task ID

**Examples:**
```bash
# Most templates require a preset
coder task create \
  --template Tasks-test-preinstall \
  --preset "Real World App: Angular + Django" \
  "Fix the authentication bug"

# With custom name
coder task create \
  --template my-template \
  --preset "Default" \
  --name my-task \
  "Add dark mode support"
```

### coder task status

Get task status.

```bash
coder task status <task-name>
```

**Output columns:** STATE CHANGED, STATUS, HEALTHY, STATE, MESSAGE

### coder task logs

View task/agent logs.

```bash
coder task logs <task-name>
```

### coder task send

Send additional prompt to running task.

```bash
coder task send <task-name> "Additional instructions or context"
```

### coder task delete

Delete a task.

```bash
coder task delete <task-name>
```

## Troubleshooting Commands

### coder support bundle

Create support bundle for troubleshooting.

```bash
coder support bundle <workspace>
```

### coder netcheck

Network diagnostic information.

```bash
coder netcheck
```

### coder stat

Show resource usage in current workspace.

```bash
coder stat
coder stat cpu
coder stat mem
coder stat disk
```

### coder state

Manually manage Terraform state (advanced).

```bash
coder state pull <workspace>
coder state push <workspace> <file>
```

## Template Commands

### coder templates list

List available templates.

```bash
coder templates list
```

### coder templates versions

List template versions.

```bash
coder templates versions <template>
```

## User Commands

### coder login

Authenticate with Coder deployment.

```bash
coder login <url>
coder login <url> --token <token>
```

### coder logout

Log out of current session.

```bash
coder logout
```

### coder whoami

Show current user info.

```bash
coder whoami
```

### coder tokens

Manage personal access tokens.

```bash
coder tokens list
coder tokens create
coder tokens delete <token-id>
```
