# Changelog

All notable changes to the Coder Workspaces skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-02-06

### Added
- Initial release of Coder Workspaces skill for OpenClaw
- Workspace lifecycle management: list, create, start, stop, restart, delete
- SSH and command execution in workspaces
- AI coding agent task management for Claude Code, Aider, Goose, and others
- Helper script (coder-helper.sh) for common operations
- Comprehensive CLI command reference documentation
- Coder Tasks deep-dive guide
- Setup guide with agent workflow checklist
- Troubleshooting guide for authentication issues
- GitHub Actions workflow for automated ClawHub publishing

### Notes
- Requires coder CLI installed
- Requires CODER_URL and CODER_SESSION_TOKEN environment variables
- Most task templates require presets for proper configuration
