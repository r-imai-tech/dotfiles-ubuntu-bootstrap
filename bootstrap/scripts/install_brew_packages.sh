#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_brew_packages.sh
#  - Homebrew 経由で Git・GNU grep をインストール（またはアップデート）
#  - 前提: install_homebrew.sh が完了していること
#
# 使い方:
#   chmod +x install_brew_packages.sh
#   ./install_brew_packages.sh
#-------------------------------------------------------------------------------

# 1) brew コマンドが存在しなければ、Homebrew の環境を読み込む
if ! command -v brew &>/dev/null; then
  if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    log "【install_brew_packages】brew が見つからないため、環境変数を反映します"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "[ERROR] Brew が見つかりません。install_homebrew.sh の実行を確認してください。" >&2
    exit 1
  fi
fi

# 2) Git と GNU grep のインストール
log "【install_brew_packages】brew で git, grep をインストール（またはアップデート）"
brew install git grep

# 3) インストール状況確認
log "  • git のパス: $(which git)"
log "  • grep のパス: $(which grep)"

log "【install_brew_packages】完了: git, grep が導入されました"