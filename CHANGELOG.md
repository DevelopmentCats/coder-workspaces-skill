# Changelog

All notable changes to the Coder Workspaces skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-02-06

### Changed
- Cleaned up description to remove implementation details
- Simplified README with cleaner formatting
- Replaced table with bullet list for task timing
- Removed redundant sections and improved readability

## [1.2.0] - 2026-02-06

### Changed
- Restructured skill to separate agent instructions from setup documentation
- Setup instructions moved to README.md (for humans)
- SKILL.md now assumes coder CLI is pre-installed and authenticated

### Removed
- Helper script with curl commands (security scanner flagged patterns)
- Reference files with API examples (redundant with official Coder docs)

### Security
- Removed all curl and credential-sending patterns from agent-loaded files
- Skill no longer contains install or authentication instructions

## [1.1.0] - 2026-02-06

### Added
- Initial public release of Coder Workspaces skill for OpenClaw
- Workspace lifecycle management: list, create, start, stop, restart, delete
- SSH and command execution in workspaces
- AI coding agent task management for Claude Code, Aider, Goose, and others
- Helper script (coder-helper.sh) for common operations
- Comprehensive CLI command reference documentation
- Coder Tasks deep-dive guide
- Setup guide with agent workflow checklist
- Troubleshooting guide for authentication issues
- GitHub Actions workflow for automated ClawHub publishing on tagged releases
