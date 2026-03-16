#!/usr/bin/env bash
set -uo pipefail

# ─── Dotfiles Interactive Setup ─────────────────────────────────────────────
# Cross-platform installer with interactive module selection.
# Detects macOS / Linux (Arch, Debian/Ubuntu, Fedora) and installs accordingly.
# ────────────────────────────────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Colors ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── Detect Platform ───────────────────────────────────────────────────────
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"
  DISTRO=""
  PKG=""

  case "$OS" in
    Darwin)
      PLATFORM="macos"
      PKG="brew"
      ;;
    Linux)
      PLATFORM="linux"
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
      fi
      case "$DISTRO" in
        arch|endeavouros|manjaro|garuda|cachyos) PKG="pacman" ;;
        ubuntu|debian|pop|linuxmint|elementary|zorin) PKG="apt" ;;
        fedora|rhel|centos|rocky|alma) PKG="dnf" ;;
        opensuse*|suse*) PKG="zypper" ;;
        void) PKG="xbps" ;;
        *) PKG="unknown" ;;
      esac
      ;;
    *)
      PLATFORM="unknown"
      PKG="unknown"
      ;;
  esac
}

# Track whether apt update has already run this session
APT_UPDATED=0

# ─── Package Install Helper ────────────────────────────────────────────────
pkg_install() {
  local pkgs=("$@")
  if [ ${#pkgs[@]} -eq 0 ]; then
    return 0
  fi

  echo -e "  ${CYAN}Installing:${RESET} ${pkgs[*]}"

  case "$PKG" in
    brew)
      brew install "${pkgs[@]}" || true
      ;;
    pacman)
      sudo pacman -S --needed --noconfirm "${pkgs[@]}" || true
      ;;
    apt)
      if [ "$APT_UPDATED" -eq 0 ]; then
        sudo apt-get update -qq
        APT_UPDATED=1
      fi
      sudo apt-get install -y "${pkgs[@]}" || true
      ;;
    dnf)
      sudo dnf install -y "${pkgs[@]}" || true
      ;;
    zypper)
      sudo zypper install -y "${pkgs[@]}" || true
      ;;
    xbps)
      sudo xbps-install -y "${pkgs[@]}" || true
      ;;
    *)
      echo -e "  ${YELLOW}Unknown package manager. Install manually: ${pkgs[*]}${RESET}"
      return 0
      ;;
  esac
}

# ─── Symlink Helpers ──────────────────────────────────────────────────────
link_file() {
  local src="$1" dst="$2"

  if [ ! -e "$src" ]; then
    echo -e "  ${RED}Source not found:${RESET} $src"
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="${dst}.bak.$(date +%s)"
    echo -e "  ${YELLOW}Backing up${RESET} $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -sf "$src" "$dst"
  echo -e "  ${GREEN}Linked${RESET} $dst"
}

link_dir() {
  local src="$1" dst="$2"

  if [ ! -d "$src" ]; then
    echo -e "  ${RED}Source dir not found:${RESET} $src"
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -d "$dst" ]; then
    local backup="${dst}.bak.$(date +%s)"
    echo -e "  ${YELLOW}Backing up${RESET} $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -sf "$src" "$dst"
  echo -e "  ${GREEN}Linked${RESET} $dst"
}

# ─── Module Definitions ───────────────────────────────────────────────────
MODULE_NAMES=(
  "Neovim"
  "Tmux"
  "Shell"
  "Git"
  "Starship"
  "Terminals"
  "Dev Tools"
  "Linux Desktop"
)

MODULE_DESCS=(
  "LazyVim config with LSP, themes, and language support"
  "Terminal multiplexer with custom keybindings and status bar"
  "Bash/Zsh configs with aliases and tool integrations"
  "Git aliases, rebase-on-pull, rerere, and sane defaults"
  "Minimal cross-shell prompt with git status"
  "Alacritty + Kitty + Ghostty terminal emulator configs"
  "Lazygit, Mise, Btop, Fastfetch"
  "Hyprland, Waybar, Walker, and more (Linux only)"
)

MODULE_PLATFORMS=(
  "all"
  "all"
  "all"
  "all"
  "all"
  "all"
  "all"
  "linux"
)

# Track which modules are selected (1=selected, 0=not)
MODULE_SELECTED=(1 1 0 0 0 0 0 0)

# ─── Dependency Installers ────────────────────────────────────────────────
deps_neovim() {
  case "$PKG" in
    brew)    pkg_install neovim ripgrep fd ;;
    pacman)  pkg_install neovim ripgrep fd ;;
    apt)     pkg_install neovim ripgrep fd-find ;;
    dnf)     pkg_install neovim ripgrep fd-find ;;
    zypper)  pkg_install neovim ripgrep fd ;;
    xbps)    pkg_install neovim ripgrep fd ;;
    *)       echo -e "  ${YELLOW}Install neovim, ripgrep, fd manually${RESET}" ;;
  esac
}

deps_tmux() {
  pkg_install tmux
}

deps_shell() {
  :
}

deps_git() {
  pkg_install git
}

deps_starship() {
  if command -v starship &>/dev/null; then
    echo -e "  ${DIM}starship already installed${RESET}"
    return 0
  fi
  echo -e "  ${CYAN}Installing starship...${RESET}"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

deps_terminals() {
  case "$PKG" in
    brew)
      echo -e "  ${DIM}On macOS, install terminal emulators from their official sites or via:${RESET}"
      echo -e "  ${DIM}  brew install --cask alacritty kitty${RESET}"
      ;;
    pacman)  pkg_install alacritty kitty ;;
    apt)     pkg_install alacritty kitty ;;
    dnf)     pkg_install alacritty kitty ;;
    zypper)  pkg_install alacritty kitty ;;
    xbps)    pkg_install alacritty kitty ;;
    *)       echo -e "  ${YELLOW}Install alacritty, kitty manually${RESET}" ;;
  esac
}

deps_devtools() {
  case "$PKG" in
    brew)    pkg_install lazygit mise btop fastfetch ;;
    pacman)  pkg_install lazygit mise btop fastfetch ;;
    apt)
      pkg_install btop fastfetch
      if ! command -v lazygit &>/dev/null; then
        echo -e "  ${DIM}lazygit: install from https://github.com/jesseduffield/lazygit${RESET}"
      fi
      if ! command -v mise &>/dev/null; then
        echo -e "  ${DIM}mise: install from https://mise.jdx.dev${RESET}"
      fi
      ;;
    dnf)
      pkg_install btop fastfetch
      if ! command -v lazygit &>/dev/null; then
        echo -e "  ${DIM}lazygit: install from https://github.com/jesseduffield/lazygit${RESET}"
      fi
      if ! command -v mise &>/dev/null; then
        echo -e "  ${DIM}mise: install from https://mise.jdx.dev${RESET}"
      fi
      ;;
    *)       echo -e "  ${YELLOW}Install lazygit, mise, btop, fastfetch manually${RESET}" ;;
  esac
}

deps_linux_desktop() {
  echo -e "  ${DIM}Linux desktop packages are managed by your distro. Skipping dependency install.${RESET}"
}

# ─── Install Functions ─────────────────────────────────────────────────────
install_neovim() {
  echo -e "\n  ${BOLD}[Neovim]${RESET}"
  deps_neovim
  link_dir "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
}

install_tmux() {
  echo -e "\n  ${BOLD}[Tmux]${RESET}"
  deps_tmux
  link_dir "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
}

install_shell() {
  echo -e "\n  ${BOLD}[Shell]${RESET}"
  deps_shell
  link_file "$DOTFILES_DIR/shell/bashrc" "$HOME/.bashrc"
  link_file "$DOTFILES_DIR/shell/bash_profile" "$HOME/.bash_profile"
  link_file "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/shell/profile" "$HOME/.profile"
}

install_git() {
  echo -e "\n  ${BOLD}[Git]${RESET}"
  deps_git
  link_file "$DOTFILES_DIR/git/config" "$HOME/.config/git/config"
  link_file "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"

  if ! git config --global user.name &>/dev/null; then
    echo ""
    echo -e "  ${YELLOW}Don't forget to set your git identity:${RESET}"
    echo -e "    git config --global user.name \"Your Name\""
    echo -e "    git config --global user.email \"your@email.com\""
  fi
}

install_starship() {
  echo -e "\n  ${BOLD}[Starship]${RESET}"
  deps_starship
  link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
}

install_terminals() {
  echo -e "\n  ${BOLD}[Terminals]${RESET}"
  deps_terminals
  link_dir "$DOTFILES_DIR/terminals/alacritty" "$HOME/.config/alacritty"
  link_dir "$DOTFILES_DIR/terminals/kitty" "$HOME/.config/kitty"
  link_dir "$DOTFILES_DIR/terminals/ghostty" "$HOME/.config/ghostty"
  echo -e "  ${DIM}Note: Terminal themes reference Omarchy theme files.${RESET}"
  echo -e "  ${DIM}Without Omarchy, replace theme imports with inline colors.${RESET}"
}

install_devtools() {
  echo -e "\n  ${BOLD}[Dev Tools]${RESET}"
  deps_devtools
  link_dir "$DOTFILES_DIR/tools/lazygit" "$HOME/.config/lazygit"
  link_dir "$DOTFILES_DIR/tools/mise" "$HOME/.config/mise"
  link_dir "$DOTFILES_DIR/tools/btop" "$HOME/.config/btop"
  link_dir "$DOTFILES_DIR/tools/fastfetch" "$HOME/.config/fastfetch"
}

install_linux_desktop() {
  echo -e "\n  ${BOLD}[Linux Desktop]${RESET}"
  deps_linux_desktop
  link_dir "$DOTFILES_DIR/linux/hypr" "$HOME/.config/hypr"
  link_dir "$DOTFILES_DIR/linux/waybar" "$HOME/.config/waybar"
  link_dir "$DOTFILES_DIR/linux/walker" "$HOME/.config/walker"
  link_dir "$DOTFILES_DIR/linux/fontconfig" "$HOME/.config/fontconfig"
  link_dir "$DOTFILES_DIR/linux/swayosd" "$HOME/.config/swayosd"
  link_dir "$DOTFILES_DIR/linux/imv" "$HOME/.config/imv"
  link_dir "$DOTFILES_DIR/linux/environment.d" "$HOME/.config/environment.d"
  link_dir "$DOTFILES_DIR/linux/uwsm" "$HOME/.config/uwsm"
  link_dir "$DOTFILES_DIR/linux/xournalpp" "$HOME/.config/xournalpp"
  echo -e "  ${DIM}Note: Hyprland configs reference Omarchy defaults.${RESET}"
  echo -e "  ${DIM}Install Omarchy or adjust source paths as needed.${RESET}"
}

INSTALL_FUNCS=(
  install_neovim
  install_tmux
  install_shell
  install_git
  install_starship
  install_terminals
  install_devtools
  install_linux_desktop
)

# ─── UI ───────────────────────────────────────────────────────────────────
print_header() {
  clear
  echo ""
  echo -e "  ${BOLD}${CYAN}Dotfiles Setup${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"
  echo -e "  ${DIM}Platform:${RESET} ${BOLD}$PLATFORM${RESET} ${DIM}($ARCH)${RESET}"
  if [ -n "$DISTRO" ]; then
    echo -e "  ${DIM}Distro:${RESET}   ${BOLD}$DISTRO${RESET}"
  fi
  echo -e "  ${DIM}Package:${RESET}  ${BOLD}$PKG${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"
  echo ""
}

print_menu() {
  echo -e "  ${BOLD}Select modules to install:${RESET}"
  echo ""

  for i in "${!MODULE_NAMES[@]}"; do
    local name="${MODULE_NAMES[$i]}"
    local desc="${MODULE_DESCS[$i]}"
    local plat="${MODULE_PLATFORMS[$i]}"
    local sel="${MODULE_SELECTED[$i]}"
    local num=$((i + 1))

    local available=1
    if [[ "$plat" == "linux" && "$PLATFORM" != "linux" ]]; then
      available=0
    fi

    if [ "$available" -eq 0 ]; then
      echo -e "  ${DIM}     $num. $name  (Linux only)${RESET}"
    elif [ "$sel" -eq 1 ]; then
      echo -e "  ${GREEN}[x]${RESET} ${BOLD}$num.${RESET} ${BOLD}$name${RESET}  ${DIM}$desc${RESET}"
    else
      echo -e "  ${DIM}[ ]${RESET} ${BOLD}$num.${RESET} $name  ${DIM}$desc${RESET}"
    fi
  done

  echo ""
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"
  echo -e "  ${BOLD}Toggle:${RESET} ${CYAN}1-${#MODULE_NAMES[@]}${RESET}  ${BOLD}All:${RESET} ${CYAN}a${RESET}  ${BOLD}None:${RESET} ${CYAN}n${RESET}  ${BOLD}Install:${RESET} ${CYAN}Enter${RESET}  ${BOLD}Quit:${RESET} ${CYAN}q${RESET}"
}

run_menu() {
  while true; do
    print_header
    print_menu
    echo ""
    echo -n "  > "

    if ! read -r choice; then
      # Handle EOF (Ctrl+D)
      echo ""
      echo -e "\n  ${DIM}Cancelled.${RESET}\n"
      exit 0
    fi

    case "$choice" in
      [1-9])
        local idx=$((choice - 1))
        if [ "$idx" -lt "${#MODULE_NAMES[@]}" ]; then
          local plat="${MODULE_PLATFORMS[$idx]}"
          if [[ "$plat" == "linux" && "$PLATFORM" != "linux" ]]; then
            continue
          fi
          if [ "${MODULE_SELECTED[$idx]}" -eq 1 ]; then
            MODULE_SELECTED[$idx]=0
          else
            MODULE_SELECTED[$idx]=1
          fi
        fi
        ;;
      a|A)
        for i in "${!MODULE_NAMES[@]}"; do
          local plat="${MODULE_PLATFORMS[$i]}"
          if [[ "$plat" != "linux" || "$PLATFORM" == "linux" ]]; then
            MODULE_SELECTED[$i]=1
          fi
        done
        ;;
      n|N)
        for i in "${!MODULE_NAMES[@]}"; do
          MODULE_SELECTED[$i]=0
        done
        ;;
      q|Q)
        echo -e "\n  ${DIM}Cancelled.${RESET}\n"
        exit 0
        ;;
      "")
        return 0
        ;;
    esac
  done
}

confirm_install() {
  local selected=()
  for i in "${!MODULE_NAMES[@]}"; do
    if [ "${MODULE_SELECTED[$i]}" -eq 1 ]; then
      selected+=("${MODULE_NAMES[$i]}")
    fi
  done

  if [ ${#selected[@]} -eq 0 ]; then
    echo -e "\n  ${YELLOW}No modules selected.${RESET}\n"
    exit 0
  fi

  echo ""
  echo -e "  ${BOLD}Will install:${RESET} ${selected[*]}"
  echo ""
  echo -n "  Proceed? [Y/n] "

  if ! read -r yn; then
    echo ""
    exit 0
  fi

  if [[ "$yn" =~ ^[Nn]$ ]]; then
    echo -e "\n  ${DIM}Cancelled.${RESET}\n"
    exit 0
  fi
}

run_install() {
  local total=0 ok=0 fail=0
  for i in "${!MODULE_NAMES[@]}"; do
    if [ "${MODULE_SELECTED[$i]}" -eq 1 ]; then
      total=$((total + 1))
    fi
  done

  echo ""
  echo -e "  ${BOLD}${CYAN}Installing $total module(s)...${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"

  for i in "${!MODULE_NAMES[@]}"; do
    if [ "${MODULE_SELECTED[$i]}" -eq 1 ]; then
      if ${INSTALL_FUNCS[$i]}; then
        ok=$((ok + 1))
      else
        fail=$((fail + 1))
        echo -e "  ${RED}Failed: ${MODULE_NAMES[$i]}${RESET}"
      fi
    fi
  done

  echo ""
  echo -e "  ${DIM}────────────────────────────────────────${RESET}"
  if [ "$fail" -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}Done!${RESET} ${DIM}($ok/$total modules installed)${RESET}"
  else
    echo -e "  ${YELLOW}${BOLD}Done with errors.${RESET} ${DIM}($ok/$total succeeded, $fail failed)${RESET}"
  fi
  echo ""
  echo -e "  ${DIM}Restart your shell or run:${RESET}  source ~/.bashrc"
  echo ""
}

# ─── Homebrew check (macOS) ───────────────────────────────────────────────
check_homebrew() {
  if [[ "$PLATFORM" != "macos" ]]; then
    return 0
  fi

  if command -v brew &>/dev/null; then
    return 0
  fi

  # Check if any selected module actually needs packages
  local needs_pkg=0
  for i in "${!MODULE_NAMES[@]}"; do
    if [ "${MODULE_SELECTED[$i]}" -eq 1 ]; then
      local name="${MODULE_NAMES[$i]}"
      # Shell module doesn't need a package manager
      if [[ "$name" != "Shell" ]]; then
        needs_pkg=1
        break
      fi
    fi
  done

  if [ "$needs_pkg" -eq 0 ]; then
    return 0
  fi

  echo -e "  ${YELLOW}Homebrew not found. Install it? [y/N]${RESET}"
  echo -n "  > "
  read -r yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo -e "  ${YELLOW}Skipping Homebrew. Package installation may fail.${RESET}"
  fi
}

# ─── Ctrl+C handler ──────────────────────────────────────────────────────
trap 'echo -e "\n\n  ${DIM}Interrupted.${RESET}\n"; exit 130' INT

# ─── Main ──────────────────────────────────────────────────────────────────
main() {
  detect_platform

  if [[ "$PLATFORM" == "unknown" ]]; then
    echo -e "${RED}Unsupported platform: $(uname -s)${RESET}"
    exit 1
  fi

  run_menu
  confirm_install
  check_homebrew
  run_install
}

main "$@"
