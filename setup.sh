#!/usr/bin/env bash
set -uo pipefail

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
    brew)    brew install "${pkgs[@]}" || true ;;
    pacman)  sudo pacman -S --needed --noconfirm "${pkgs[@]}" || true ;;
    apt)
      if [ "$APT_UPDATED" -eq 0 ]; then
        sudo apt-get update -qq
        APT_UPDATED=1
      fi
      sudo apt-get install -y "${pkgs[@]}" || true
      ;;
    dnf)     sudo dnf install -y "${pkgs[@]}" || true ;;
    zypper)  sudo zypper install -y "${pkgs[@]}" || true ;;
    xbps)    sudo xbps-install -y "${pkgs[@]}" || true ;;
    *)       echo -e "  ${YELLOW}Unknown package manager. Install manually: ${pkgs[*]}${RESET}" ;;
  esac
}

# ─── Symlink Helper ──────────────────────────────────────────────────────
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
MODULE_NAMES=("Neovim" "Tmux" "Ghostty")
MODULE_DESCS=(
  "LazyVim config with LSP, themes, and language support"
  "Terminal multiplexer with vi mode, splits, and themed status bar"
  "GPU-accelerated terminal emulator config"
)
MODULE_SELECTED=(1 1 1)

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

deps_ghostty() {
  case "$PKG" in
    brew)    echo -e "  ${DIM}Install Ghostty from https://ghostty.org${RESET}" ;;
    pacman)  pkg_install ghostty ;;
    *)       echo -e "  ${DIM}Install Ghostty from https://ghostty.org${RESET}" ;;
  esac
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

install_ghostty() {
  echo -e "\n  ${BOLD}[Ghostty]${RESET}"
  deps_ghostty
  link_dir "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
}

INSTALL_FUNCS=(install_neovim install_tmux install_ghostty)

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
    local num=$((i + 1))
    if [ "${MODULE_SELECTED[$i]}" -eq 1 ]; then
      echo -e "  ${GREEN}[x]${RESET} ${BOLD}$num.${RESET} ${BOLD}${MODULE_NAMES[$i]}${RESET}  ${DIM}${MODULE_DESCS[$i]}${RESET}"
    else
      echo -e "  ${DIM}[ ]${RESET} ${BOLD}$num.${RESET} ${MODULE_NAMES[$i]}  ${DIM}${MODULE_DESCS[$i]}${RESET}"
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
      echo -e "\n  ${DIM}Cancelled.${RESET}\n"
      exit 0
    fi

    case "$choice" in
      [1-3])
        local idx=$((choice - 1))
        if [ "${MODULE_SELECTED[$idx]}" -eq 1 ]; then
          MODULE_SELECTED[$idx]=0
        else
          MODULE_SELECTED[$idx]=1
        fi
        ;;
      a|A) for i in "${!MODULE_NAMES[@]}"; do MODULE_SELECTED[$i]=1; done ;;
      n|N) for i in "${!MODULE_NAMES[@]}"; do MODULE_SELECTED[$i]=0; done ;;
      q|Q) echo -e "\n  ${DIM}Cancelled.${RESET}\n"; exit 0 ;;
      "")  return 0 ;;
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
  echo -n "  Proceed? [Y/n] "

  if ! read -r yn; then
    echo ""; exit 0
  fi

  if [[ "$yn" =~ ^[Nn]$ ]]; then
    echo -e "\n  ${DIM}Cancelled.${RESET}\n"
    exit 0
  fi
}

run_install() {
  local total=0 ok=0 fail=0
  for i in "${!MODULE_NAMES[@]}"; do
    [ "${MODULE_SELECTED[$i]}" -eq 1 ] && total=$((total + 1))
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
    echo -e "  ${GREEN}${BOLD}Done!${RESET} ${DIM}($ok/$total installed)${RESET}"
  else
    echo -e "  ${YELLOW}${BOLD}Done with errors.${RESET} ${DIM}($ok/$total succeeded, $fail failed)${RESET}"
  fi
  echo ""
}

# ─── Homebrew check (macOS) ───────────────────────────────────────────────
check_homebrew() {
  if [[ "$PLATFORM" == "macos" ]] && ! command -v brew &>/dev/null; then
    echo -e "  ${YELLOW}Homebrew not found. Install it? [y/N]${RESET}"
    echo -n "  > "
    read -r yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo -e "  ${YELLOW}Skipping Homebrew. Package installation may fail.${RESET}"
    fi
  fi
}

trap 'echo -e "\n\n  ${DIM}Interrupted.${RESET}\n"; exit 130' INT

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
