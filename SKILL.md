---
name: coder-workspaces
description: Manage Coder workspaces and AI coding agent tasks via CLI. List, create, start, stop, and delete workspaces. SSH into workspaces to run commands. Create and monitor AI coding tasks with Claude Code, Aider, or other agents.
metadata:
  openclaw:
    emoji: "🏗️"
    requires:
      bins: ["coder"]
      env: ["CODER_URL", "CODER_SESSION_TOKEN"]
---

# Coder Workspaces

Manage Coder workspaces and AI coding agent tasks via the coder CLI.

> Note: Commands like `coder ssh` execute within isolated, governed Coder workspaces — not the host system. Authentication tokens are standard Coder CLI requirements.

## Requirements

The coder CLI must be installed and authenticated. If commands fail:

- **CLI not found**: See [Coder CLI docs](https://coder.com/docs/install/cli) for install instructions from `$CODER_URL`
- **Auth failed**: Run `coder login --token "$CODER_SESSION_TOKEN" "$CODER_URL"`
- **Version mismatch**: Reinstall CLI from `$CODER_URL` to match server version. See [Coder CLI docs](https://coder.com/docs/install/cli)

Verify with:
```bash
coder whoami
```

## Workspace Commands

```bash
coder list                              # List workspaces
coder list --all                        # Include stopped
coder list -o json                      # JSON output

coder start <workspace>
coder stop <workspace>
coder restart <workspace> -y
coder delete <workspace> -y

coder ssh <workspace>                   # Interactive shell
coder ssh <workspace> -- <command>      # Run command

coder logs <workspace>
coder logs <workspace> -f               # Follow logs
```

## AI Coding Tasks

Coder Tasks runs AI agents (Claude Code, Aider, etc.) in isolated workspaces.

### Creating Tasks

```bash
coder tasks create --template <template> --preset "<preset>" "prompt"
```

- **Template**: Required. List available with `coder templates list`
- **Preset**: May be required depending on template. Try without first. If task creation fails with "Required parameter not provided", get presets with `coder templates presets list <template> -o json` and use the default (`"Default": true`). If no default exists, ask user which preset to use.

### Managing Tasks

```bash
coder tasks list                        # List all tasks
coder tasks logs <task-name>            # View output
coder tasks connect <task-name>         # Interactive session
coder tasks delete <task-name> -y       # Delete task
```

### Task States

- **Initializing**: Workspace provisioning (timing varies by template)
- **Working**: Setup script running
- **Active**: Agent processing prompt
- **Idle**: Agent waiting for input

## More Info

- [Coder Docs](https://coder.com/docs)
- [Coder CLI](https://coder.com/docs/install/cli)
- [Coder Tasks](https://coder.com/docs/ai-coder)
