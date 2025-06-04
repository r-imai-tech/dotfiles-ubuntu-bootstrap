#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_homebrew.sh
#  - Homebrew（Linuxbrew）をインストールするスクリプト
#  - 前提: install_apt_deps.sh がすでに完了していること
#
# 使い方:
#   chmod +x install_homebrew.sh
#   ./install_homebrew.sh
#-------------------------------------------------------------------------------

# 1) APT deps は install_apt_deps.sh で対応している想定
if ! command -v brew &>/dev/null; then
  log "【install_homebrew】Homebrew が見つからないため、インストールを開始します"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  log "【install_homebrew】Homebrew の環境変数設定を ~/.profile に追記"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile

  log "【install_homebrew】現在のシェルに Homebrew のパスを反映"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  log "【install_homebrew】Homebrew はすでにインストール済みです"
  # PATH に brew が通っていなければ一時的に通す
  if [ -d "/home/linuxbrew/.linuxbrew/bin" ] && ! echo "$PATH" | grep -q "/home/linuxbrew/.linuxbrew/bin"; then
    log "【install_homebrew】Homebrew のパスを現在のシェルに追加"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

log "【install_homebrew】完了: Homebrew がインストールされました"