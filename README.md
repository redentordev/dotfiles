# Dotfiles

Personal development environment configs. Cross-platform (macOS + Linux).

## Quick Start

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The interactive installer detects your OS and package manager, then lets you pick which modules to install.

## Modules

| Module | What's included | Platform |
|--------|----------------|----------|
| **Neovim** | LazyVim + LSP, themes, oil.nvim, Flutter/TS/C# support | All |
| **Tmux** | Ctrl+A prefix, vi mode, pane/window/session bindings, themed status bar | All |
| **Shell** | Bash + Zsh configs with aliases, PATH setup, tool integrations | All |
| **Git** | Aliases, rebase-on-pull, rerere, histogram diff | All |
| **Starship** | Minimal prompt with git status and directory truncation | All |
| **Terminals** | Alacritty, Kitty, Ghostty (JetBrainsMono Nerd Font, size 9) | All |
| **Dev Tools** | Lazygit, Mise, Btop, Fastfetch | All |
| **Linux Desktop** | Hyprland, Waybar, Walker, SwayOSD, and more | Linux |

## Structure

```
nvim/           Neovim config (LazyVim)      -> ~/.config/nvim/
tmux/           Tmux config                  -> ~/.config/tmux/
shell/          Bash/Zsh configs             -> ~/.*rc
git/            Git config + global ignore   -> ~/.config/git/
starship/       Starship prompt              -> ~/.config/starship.toml
terminals/      Alacritty, Kitty, Ghostty    -> ~/.config/{alacritty,kitty,ghostty}/
tools/          Lazygit, Mise, Btop, etc.    -> ~/.config/{lazygit,mise,btop,fastfetch}/
linux/          Hyprland desktop configs     -> ~/.config/{hypr,waybar,...}/
```

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
| `P` / `N` | Previous / next session |
| `z` | Toggle zoom |
| `q` | Reload config |

### Neovim

LazyVim defaults plus:

| Key | Action |
|-----|--------|
| `<leader>fc` | Colorscheme picker |
| `<leader>fw` | Find word under cursor |
| `<leader>ft` | Treesitter symbols |
| `<leader>sh/sv` | Horizontal/vertical split |
| `-` | Open parent directory (oil.nvim) |
| `<leader>w/q` | Save / Quit |
| `J/K` (visual) | Move text down/up |

## Dependencies

Installed automatically by `setup.sh`:

- **Neovim**: `neovim`, `ripgrep`, `fd`
- **Tmux**: `tmux`
- **Git**: `git`
- **Starship**: installed via official script
- **Font**: [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) (install manually)

## Notes

- **Terminal theme files** reference Omarchy theme imports. Without Omarchy, replace the `import` lines with inline color definitions.
- **Linux Desktop configs** (Hyprland, Waybar, etc.) depend on [Omarchy](https://github.com/nicholasgasior/omarchy) and related tools. They are only offered during setup on Linux.
- **Flutter plugin** looks for `$FLUTTER_SDK` env var, falling back to `~/.flutter-sdk/flutter`.
- Existing configs are backed up to `*.bak.<timestamp>` before being overwritten.
