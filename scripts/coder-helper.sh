#!/bin/bash
# Coder CLI Helper Script
# Smart operations for workspace and task management

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Check prerequisites
check_env() {
    if [ -z "${CODER_URL:-}" ]; then
        log_error "CODER_URL not set"
        return 1
    fi
    if [ -z "${CODER_SESSION_TOKEN:-}" ]; then
        log_error "CODER_SESSION_TOKEN not set"
        return 1
    fi
    if ! command -v coder &>/dev/null; then
        log_error "coder CLI not found"
        log_info "Install: curl -fsSL $CODER_URL/install.sh | sh"
        return 1
    fi
    log_info "Connected to: $CODER_URL"
}

# List workspaces with optional filter
list_workspaces() {
    local filter="${1:-owner:me}"
    coder list --search "$filter" -o json 2>/dev/null
}

# Get workspace status
workspace_status() {
    local name="$1"
    coder list --search "name:$name" -o json 2>/dev/null | jq -r '.[0].latest_build.status // "not found"'
}

# Ensure workspace is running
ensure_running() {
    local name="$1"
    local status
    status=$(workspace_status "$name")
    
    case "$status" in
        running)
            log_info "Workspace '$name' is running"
            ;;
        stopped|failed)
            log_info "Starting workspace '$name'..."
            coder start "$name" -y 2>/dev/null
            wait_for_workspace "$name" "running" 180
            ;;
        starting|stopping)
            log_info "Workspace '$name' is $status, waiting..."
            wait_for_workspace "$name" "running" 180
            ;;
        *)
            log_error "Workspace '$name' not found or unknown status: $status"
            return 1
            ;;
    esac
}

# Wait for workspace to reach desired status
wait_for_workspace() {
    local name="$1"
    local desired="${2:-running}"
    local timeout="${3:-180}"
    local elapsed=0
    local interval=10

    log_step "Waiting for workspace '$name' to be $desired..."
    while [ "$elapsed" -lt "$timeout" ]; do
        local status
        status=$(workspace_status "$name")
        if [ "$status" = "$desired" ]; then
            log_info "Workspace '$name' is now $desired"
            return 0
        fi
        sleep "$interval"
        elapsed=$((elapsed + interval))
        echo -n "."
    done
    echo
    log_error "Timeout waiting for workspace '$name'"
    return 1
}

# Run command in workspace
run_in_workspace() {
    local workspace="$1"
    shift
    local cmd="$*"
    
    ensure_running "$workspace"
    coder ssh "$workspace" -- bash -c "$cmd" 2>/dev/null
}

# Get template presets
get_presets() {
    local template="$1"
    
    # Get template's active version ID
    local version_id
    version_id=$(curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
        "$CODER_URL/api/v2/templates" 2>/dev/null | \
        jq -r ".[] | select(.name==\"$template\") | .active_version_id")
    
    if [ -z "$version_id" ] || [ "$version_id" = "null" ]; then
        log_error "Template '$template' not found"
        return 1
    fi
    
    # Get presets
    curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
        "$CODER_URL/api/v2/templateversions/$version_id/presets" 2>/dev/null | \
        jq -r '.[] | "\(.Name)\t\(.Default)"'
}

# Get default preset for template
get_default_preset() {
    local template="$1"
    
    local version_id
    version_id=$(curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
        "$CODER_URL/api/v2/templates" 2>/dev/null | \
        jq -r ".[] | select(.name==\"$template\") | .active_version_id")
    
    if [ -z "$version_id" ] || [ "$version_id" = "null" ]; then
        return 1
    fi
    
    curl -s -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
        "$CODER_URL/api/v2/templateversions/$version_id/presets" 2>/dev/null | \
        jq -r '.[] | select(.Default == true) | .Name'
}

# Create task with smart preset detection
create_task() {
    local template="$1"
    local prompt="$2"
    local preset="${3:-}"
    
    # Auto-detect preset if not provided
    if [ -z "$preset" ]; then
        log_step "Detecting default preset for template '$template'..."
        preset=$(get_default_preset "$template")
        if [ -n "$preset" ]; then
            log_info "Using default preset: $preset"
        else
            log_warn "No default preset found. Listing available presets:"
            get_presets "$template"
            log_error "Please specify a preset with: $0 create-task <template> <prompt> <preset>"
            return 1
        fi
    fi
    
    log_step "Creating task with template '$template' and preset '$preset'..."
    coder task create --template "$template" --preset "$preset" "$prompt" 2>/dev/null
}

# Wait for task to reach active state
wait_for_task() {
    local task_name="$1"
    local timeout="${2:-300}"  # Default 5 minutes for task startup
    local interval="${3:-15}"
    
    local elapsed=0
    log_step "Waiting for task '$task_name' to become active (timeout: ${timeout}s)..."
    
    while [ "$elapsed" -lt "$timeout" ]; do
        local status state message
        local status_output
        status_output=$(coder task status "$task_name" 2>/dev/null | tail -1)
        
        status=$(echo "$status_output" | awk '{print $2}')
        state=$(echo "$status_output" | awk '{print $4}')
        message=$(echo "$status_output" | awk '{for(i=5;i<=NF;i++) printf $i" "; print ""}')
        
        case "$status" in
            active)
                if [ "$state" = "idle" ]; then
                    log_info "Task '$task_name' completed! Message: $message"
                    return 0
                else
                    log_info "Task active and working: $message"
                fi
                ;;
            error)
                log_error "Task '$task_name' failed: $message"
                return 1
                ;;
            initializing)
                echo -ne "\r${BLUE}[WAIT]${NC} Initializing ($message) - ${elapsed}s elapsed"
                ;;
            *)
                echo -ne "\r${BLUE}[WAIT]${NC} Status: $status, State: $state - ${elapsed}s elapsed"
                ;;
        esac
        
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done
    
    echo
    log_warn "Task '$task_name' still running after ${timeout}s (this may be normal for long tasks)"
    return 0
}

# Diagnose workspace issues
diagnose_workspace() {
    local name="$1"
    
    log_info "=== Diagnosing workspace: $name ==="
    
    log_step "Status:"
    coder list --search "name:$name" -o json 2>/dev/null | \
        jq '.[0] | {name, status: .latest_build.status, healthy: .health.healthy, template: .template_name}'
    
    log_step "Recent build logs (last 20 lines):"
    coder logs "$name" 2>/dev/null | tail -20 || log_warn "Could not fetch logs"
    
    log_step "Connectivity test:"
    timeout 10 coder ping "$name" 2>/dev/null || log_warn "Ping failed or timed out"
}

# Diagnose task issues
diagnose_task() {
    local name="$1"
    
    log_info "=== Diagnosing task: $name ==="
    
    log_step "Task status:"
    coder task status "$name" 2>/dev/null
    
    log_step "Task logs (last 30 lines):"
    coder task logs "$name" 2>/dev/null | tail -30 || log_warn "Could not fetch task logs"
}

# Main command dispatcher
main() {
    local cmd="${1:-help}"
    shift || true
    
    case "$cmd" in
        check)
            check_env
            ;;
        list)
            list_workspaces "${1:-owner:me}"
            ;;
        status)
            [ -z "${1:-}" ] && { log_error "Usage: $0 status <workspace>"; exit 1; }
            workspace_status "$1"
            ;;
        ensure-running)
            [ -z "${1:-}" ] && { log_error "Usage: $0 ensure-running <workspace>"; exit 1; }
            check_env && ensure_running "$1"
            ;;
        run)
            [ -z "${1:-}" ] && { log_error "Usage: $0 run <workspace> <command>"; exit 1; }
            local ws="$1"; shift
            check_env && run_in_workspace "$ws" "$@"
            ;;
        logs)
            [ -z "${1:-}" ] && { log_error "Usage: $0 logs <workspace> [lines]"; exit 1; }
            coder logs "$1" 2>/dev/null | tail -n "${2:-100}"
            ;;
        diagnose)
            [ -z "${1:-}" ] && { log_error "Usage: $0 diagnose <workspace>"; exit 1; }
            check_env && diagnose_workspace "$1"
            ;;
        diagnose-task)
            [ -z "${1:-}" ] && { log_error "Usage: $0 diagnose-task <task-name>"; exit 1; }
            check_env && diagnose_task "$1"
            ;;
        presets)
            [ -z "${1:-}" ] && { log_error "Usage: $0 presets <template>"; exit 1; }
            check_env && get_presets "$1"
            ;;
        create-task)
            [ -z "${1:-}" ] || [ -z "${2:-}" ] && { 
                log_error "Usage: $0 create-task <template> <prompt> [preset]"
                exit 1
            }
            check_env && create_task "$1" "$2" "${3:-}"
            ;;
        wait-task)
            [ -z "${1:-}" ] && { log_error "Usage: $0 wait-task <task-name> [timeout] [interval]"; exit 1; }
            check_env && wait_for_task "$1" "${2:-300}" "${3:-15}"
            ;;
        tasks)
            coder task list 2>/dev/null
            ;;
        task-status)
            [ -z "${1:-}" ] && { log_error "Usage: $0 task-status <task-name>"; exit 1; }
            coder task status "$1" 2>/dev/null
            ;;
        help|*)
            cat <<EOF
Coder CLI Helper Script - Smart workspace and task management

Usage: $0 <command> [args]

WORKSPACE COMMANDS:
  check                     Check environment configuration
  list [filter]             List workspaces (default: owner:me)
  status <workspace>        Get workspace status
  ensure-running <ws>       Start workspace if not running (waits for ready)
  run <ws> <command>        Run command in workspace
  logs <ws> [lines]         Get workspace logs
  diagnose <ws>             Diagnose workspace issues

TASK COMMANDS:
  tasks                     List all tasks
  task-status <name>        Get task status
  presets <template>        List available presets for a template
  create-task <tpl> <prompt> [preset]
                            Create task (auto-detects preset if not provided)
  wait-task <name> [timeout] [interval]
                            Wait for task to complete (default: 300s, 15s interval)
  diagnose-task <name>      Diagnose task issues

TIMING NOTES:
  - Workspace startup: 30-60 seconds
  - Task initialization: 1-3 minutes (setup script dependent)
  - Task commands use appropriate waits automatically

ENVIRONMENT:
  CODER_URL                 Coder deployment URL
  CODER_SESSION_TOKEN       Authentication token

EXAMPLES:
  $0 check
  $0 create-task Tasks-test-preinstall "Fix the auth bug"
  $0 wait-task my-task-abc123 600
  $0 diagnose-task my-task-abc123
EOF
            ;;
    esac
}

main "$@"
