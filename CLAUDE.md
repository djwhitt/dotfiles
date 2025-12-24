# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository managed with **RCM** (rcm/lsrc). Dotfiles are symlinked to `~` using tag-based deployment.

### RCM Configuration

The rcrc file (`host-framework13/rcrc`) controls deployment:
- `TAGS="desktop"` - Enables `tag-desktop/` configs
- `DOTFILES_DIRS` - Main repo + private repo at `~/.dotfiles-private`
- `EXCLUDES="Makefile"` - Not symlinked

### Key Commands

```bash
# Deploy dotfiles (run from home directory)
rcup -v              # Install/update symlinks
lsrc                 # List what will be linked

# Babashka tasks (run from tag-desktop/)
bb ping                    # Healthcheck
bb upload-nocodb-file      # Upload file to NocoDB
bb archive-document        # Archive document in NocoDB

# Just tasks (user.justfile in tag-desktop/)
just weekly-newsletter-to-kindle
```

## Directory Structure

- `config/` - Universal configs (fish, nvim, git, atuin)
- `tag-desktop/` - Desktop-specific configs (kitty, lf, neomutt, taskwarrior)
- `tag-desktop/local/bin/` - Desktop utility scripts
- `local/bin/` - Cross-platform utility scripts
- `host-framework13/` - Host-specific overrides

## Key Applications

| App | Config Location | Notes |
|-----|-----------------|-------|
| Fish shell | `config/fish/` | Primary shell, modular conf.d/ setup |
| Neovim | `config/nvim/lua/` | Lua-based config |
| Kitty | `tag-desktop/config/kitty/` | Terminal with custom tab management |
| LF | `tag-desktop/config/lf/` | File manager with custom scripts |
| Atuin | `config/atuin/` | Shell history manager |

## Notable Scripts

### Kitty Tab Management (`tag-desktop/local/bin/`)
- `ensure-kitty-nvim-tab` - Opens Neovim in dedicated Kitty tab
- `ensure-kitty-lf-tab` - Opens LF file manager in tab
- `ensure-kitty-taskwarrior-tab` - Opens Taskwarrior in tab

### Media Processing
- `record-call` - Call recording with transcription/GPT processing
- `archive-media` - Archive files to Git Annex with SHA256

### Babashka Tasks (`tag-desktop/local/src/clj/djwhitt/tasks.clj`)
Tasks use Malli for validation and interact with NocoDB API.

## Git Conventions

- Use plain, descriptive commit messages (not conventional commits)
- Include the reason for the change, not just what changed
- If the reason is unclear, ask the user before committing

## Coding Principles

- Look for dead code and copy-pasta opportunities when making changes
- Scripts use Fish shell conventions when in `config/fish/`
- Bash scripts should include proper error handling
- Kitty scripts follow the `ensure-kitty-*-tab` pattern for tab management
