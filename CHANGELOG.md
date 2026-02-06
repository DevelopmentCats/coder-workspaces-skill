# Changelog

All notable changes to the Coder Workspaces skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-02-06

### Fixed
- Fixed GitHub Actions permissions for creating releases

## [1.0.1] - 2026-02-06

### Fixed
- Fixed GitHub Actions workflow changelog handling

### Changed
- Improved release automation

## [1.0.0] - 2026-02-06

### Added
- Initial release of Coder Workspaces skill for OpenClaw
- Workspace lifecycle management (list, create, start, stop, restart, delete)
- SSH & command execution in workspaces
- AI coding agent task management (Claude Code, Aider, Goose, etc.)
- Helper script (`coder-helper.sh`) for common operations
- Comprehensive CLI command reference
- Tasks deep-dive documentation
- Setup guide with agent workflow checklist
- Troubleshooting guide for common auth issues

### Notes
- Requires `coder` CLI and environment variables `CODER_URL`, `CODER_SESSION_TOKEN`
- Most task templates require presets — skill handles preset detection automatically
