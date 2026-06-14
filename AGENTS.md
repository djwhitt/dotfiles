# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Repository Overview

This is a dotfiles repository managed with **RCM** (rcm/lsrc). Dotfiles are symlinked to `~` using tag-based deployment.

### RCM Configuration

Deployment is controlled by a per-host rcrc file at `host-<hostname>/rcrc`:
- `host-framework13/rcrc` — `TAGS="linux"`, enables `tag-linux/` configs
- `host-Davids-MacBook-Pro/rcrc` — `TAGS="darwin"`, enables `tag-darwin/` configs

Settings common to both hosts:
- `DOTFILES_DIRS` - Main repo + private repo at `~/.dotfiles-private`
- `EXCLUDES="Makefile CLAUDE.md README.org PLAN.org"` - Not symlinked

### Key Commands

```bash
# Deploy dotfiles (run from home directory)
rcup -v              # Install/update symlinks
lsrc                 # List what will be linked

# Just tasks (user.justfile in tag-linux/)
just weekly-newsletter-to-kindle
```

## Related Repositories

### ~/Work/infra
Infrastructure repository with NixOS system configs (including framework13 laptop), AWS CDK stacks, and Ansible playbooks. See its CLAUDE.md for details.

### ~/.dotfiles-private
Companion RCM repo for sensitive configs, merged via `DOTFILES_DIRS` in rcrc. See its CLAUDE.md for details.

## Directory Structure

- `config/` - Universal configs (fish, git, atuin, bat, opencode)
- `tag-linux/` - Linux desktop configs (kitty, lf, neomutt, hypr, niri, waybar, dunst/mako, etc.)
- `tag-linux/local/bin/` - Linux desktop utility scripts
- `tag-darwin/` - macOS-specific configs (karabiner)
- `local/bin/` - Cross-platform utility scripts
- `gnupg/` - GnuPG agent/config
- `host-framework13/`, `host-Davids-MacBook-Pro/` - Host-specific rcrc overrides

## Key Applications

| App | Config Location | Notes |
|-----|-----------------|-------|
| Fish shell | `config/fish/` | Primary shell, modular conf.d/ setup |
| Kitty | `tag-linux/config/kitty/` | Terminal with hyprctl window management |
| LF | `tag-linux/config/lf/` | File manager with custom scripts |
| Atuin | `config/atuin/` | Shell history manager |
| Karabiner | `tag-darwin/config/karabiner/` | macOS key remapping (Caps Lock → Left Control) |

## Notable Scripts

### Kitty Window Management (`tag-linux/local/bin/`)
- `ensure-kitty-nvim` - Opens Neovim in dedicated Kitty window on workspace 2
- `ensure-kitty-lf` - Opens LF file manager in dedicated Kitty window
- `ensure-kitty-render` - Other dedicated-window launchers

### Media & Archival
- `record-call` (`tag-linux/local/bin/`) - Toggle call recording (mic + system audio) with transcription
- `a` (`local/bin/`) - Babashka file-archival tool
- `archive-scan` (`tag-linux/local/bin/`) - Scan paper documents (Brother scanner) and archive via `a`

## Git Conventions

- Use plain, descriptive commit messages (not conventional commits)
- Include the reason for the change, not just what changed
- If the reason is unclear, ask the user before committing

## Coding Principles

- Look for dead code and copy-pasta opportunities when making changes
- Scripts use Fish shell conventions when in `config/fish/`
- Bash scripts should use `#!/usr/bin/env bash` shebang for portability
- Bash scripts should include proper error handling
- Kitty scripts follow the `ensure-kitty-*` pattern for window management
