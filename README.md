# Dotfiles

Personal dev environment: Neovim, Tmux, and Ghostty.

## Quick Start

```bash
git clone https://github.com/redentordev/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The interactive installer detects your OS and package manager, lets you pick modules, installs dependencies, and symlinks configs (existing configs are backed up).

## What's Included

| Module | Config | Description |
|--------|--------|-------------|
| **Neovim** | `nvim/` -> `~/.config/nvim/` | LazyVim with LSP, oil.nvim, transparency, Flutter/TS/C# support |
| **Tmux** | `tmux/` -> `~/.config/tmux/` | Ctrl+A prefix, vi mode, splits, themed status bar |
| **Ghostty** | `ghostty/` -> `~/.config/ghostty/` | JetBrainsMono Nerd Font, size 9, block cursor |

## Key Bindings

### Tmux (prefix: `Ctrl+A`)

| Key | Action |
|-----|--------|
| `h` / `v` | Split horizontal / vertical |
| `Ctrl+Alt+Arrows` | Navigate panes |
| `Alt+1-9` | Switch to window N |
| `c` | New window |
| `x` | Kill pane |
| `C` | New session |
| `P` / `N` | Prev / next session |
| `z` | Toggle zoom |
| `q` | Reload config |

### Neovim

LazyVim defaults plus:

| Key | Action |
|-----|--------|
| `<leader>fc` | Colorscheme picker |
| `<leader>fw` | Find word under cursor |
| `<leader>ft` | Treesitter symbols |
| `-` | Open parent directory (oil.nvim) |
| `<leader>w` / `<leader>q` | Save / Quit |
| `J` / `K` (visual) | Move text down / up |

## Requirements

- **Font**: [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- Dependencies (`neovim`, `tmux`, `ripgrep`, `fd`) are installed automatically by `setup.sh`
